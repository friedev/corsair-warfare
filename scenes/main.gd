extends Node

signal game_over

const SHIP_SCENE := preload("res://scenes/world/ship/ship.tscn")

@export var ship_spawn_radius: float

@onready var world: Node2D = %World
@onready var camera: ShakeCamera2D = %Camera2D
@onready var wind: Wind = %Wind
@onready var music: Music = %Music
@onready var hud_layer: CanvasLayer = %HUDLayer
@onready var ship_spawn_cast: ShapeCast2D = %ShipSpawnCast

var game_active: bool:
	set(value):
		game_active = value
		self.world.visible = self.game_active
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
	ship.damage_taken.connect(self.camera._on_ship_damage_taken)
	ship.destroyed.connect(self._on_ship_destroyed)
	self.world.add_child(ship)
	ship.wind = self.wind


func _ready() -> void:
	self.game_active = false


func _on_game_restarted() -> void:
	Globals.players.clear()
	self.get_tree().reload_current_scene()


func _on_lobby_menu_players_ready() -> void:
	self.ships_alive = len(Globals.players)
	for details in Globals.players.values():
		self.spawn_ship(details)
	self.game_active = true


func _on_ship_destroyed(ship: Ship) -> void:
	self.ships_alive -= 1
	if self.ships_alive <= 1:
		self.game_over.emit()
