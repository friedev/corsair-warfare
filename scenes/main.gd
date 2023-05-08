extends Node

signal game_over

const SHIP_SCENE := preload("res://scenes/world/ship/ship.tscn")

@export var ship_spawn_radius: float
@export var low_time_threshold: float

@export var deathmatch_kill_score: int
@export var deathmatch_death_score: int
@export var deathmatch_self_destruct_score: int

@onready var world: Node2D = %World
@onready var camera: ShakeCamera2D = %Camera2D
@onready var ship_spawn_cast: ShapeCast2D = %ShipSpawnCast
@onready var wind: Wind = %Wind
@onready var music: Music = %Music
@onready var hud_layer: CanvasLayer = %HUDLayer
@onready var time_limit_label: Label = %TimeLimitLabel
@onready var score_label: RichTextLabel = %ScoreLabel
@onready var game_timer: Timer = %GameTimer

var game_active: bool:
	set(value):
		game_active = value
		self.hud_layer.visible = self.game_active
		self.get_tree().paused = not self.game_active

var ships_alive: int


func move_ship_spawn_cast() -> void:
	self.ship_spawn_cast.position = Vector2(
		self.ship_spawn_radius * sqrt(randf()), 0
	).rotated(randf() * TAU)
	self.ship_spawn_cast.force_shapecast_update()


func find_ship_spawn_position() -> Vector2:
	self.move_ship_spawn_cast()
	while self.ship_spawn_cast.get_collision_count() > 0:
		self.move_ship_spawn_cast()
	return self.ship_spawn_cast.position


func spawn_ship(details: PlayerDetails) -> void:
	var spawn_position := self.find_ship_spawn_position()
	var ship: Ship = self.SHIP_SCENE.instantiate()
	ship.details = details
	ship.position = spawn_position
	ship.rotation = randf() * TAU
	ship.cannon_fired.connect(self.music._on_ship_cannon_fired)
	ship.damage_taken.connect(self.music._on_ship_damage_taken)
	ship.cannon_fired.connect(self.camera._on_ship_cannon_fired)
	ship.damage_taken.connect(self.camera._on_ship_damage_taken)
	ship.destroyed.connect(self._on_ship_destroyed)
	self.world.add_child.call_deferred(ship)
	ship.wind = self.wind


func _ready() -> void:
	self.game_active = false


func _process(delta: float) -> void:
	var total_seconds_left := ceili(self.game_timer.time_left)
	var minutes_left := total_seconds_left / 60
	var seconds_left := total_seconds_left % 60
	self.time_limit_label.text = "%d:%02d" % [minutes_left, seconds_left]
	if total_seconds_left < Globals.time_limit_seconds * self.low_time_threshold:
		self.time_limit_label.modulate = Color(1, 0.25, 0.25)
	else:
		self.time_limit_label.modulate = Color.WHITE


func _on_game_restarted() -> void:
	for details in Globals.players.values():
		details.score = 0
	# We could also try to free splashes and impacts here, but they have short
	# lifespans and don't affect the game
	self.get_tree().call_group(&"ships", &"queue_free")
	self.get_tree().call_group(&"cannonballs", &"queue_free")
	self.game_active = false


func sort_score_descending(
	details1: PlayerDetails,
	details2: PlayerDetails
) -> bool:
	return details1.score > details2.score


func update_score_label() -> void:
	if self.game_timer.is_stopped():
		return
	self.score_label.clear()
	var details_list := Globals.players.values()
	details_list.sort_custom(self.sort_score_descending)
	for i in range(len(details_list)):
		var details: PlayerDetails = details_list[i]
		var highest_score: bool = (
			i == 0
			and len(details_list) > 1
			and details_list[1].score < details.score
		)
		if highest_score:
			self.score_label.push_color(Color(1, 0.75, 0))
		self.score_label.add_text(
			"%d: %s\n" % [details.score, details.nickname]
		)
		if highest_score:
			self.score_label.pop()


func _on_lobby_menu_players_ready() -> void:
	self.ships_alive = len(Globals.players)
	for details in Globals.players.values():
		self.spawn_ship(details)
	self.game_active = true
	if Globals.time_limit_seconds > 0:
		self.game_timer.start(Globals.time_limit_seconds)
		self.time_limit_label.show()
	else:
		self.time_limit_label.hide()
	self.score_label.visible = Globals.game_mode == Globals.GameMode.DEATHMATCH
	self.update_score_label()


func _on_ship_destroyed(ship: Ship, destroyer: int) -> void:
	if Globals.game_mode == Globals.GameMode.LAST_MAN_STANDING:
		self.ships_alive -= 1
		if self.ships_alive <= 1:
			self.game_over.emit()
	elif Globals.game_mode == Globals.GameMode.DEATHMATCH:
		if destroyer == Globals.NO_PLAYER or destroyer == ship.details.player:
			ship.details.score += deathmatch_self_destruct_score
		else:
			Globals.players[destroyer].score += deathmatch_kill_score
			ship.details.score += deathmatch_death_score
		self.update_score_label()
		self.spawn_ship(ship.details)


func _on_game_timer_timeout() -> void:
	self.game_over.emit()
