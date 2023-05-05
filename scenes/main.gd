extends Node

signal game_over

const SHIP_SCENE := preload("res://scenes/world/ship/ship.tscn")

const SHIP_TEXTURES := [
	preload("res://scenes/world/ship/white_ship.png"),
	preload("res://scenes/world/ship/black_ship.png"),
]

@onready var world: Node2D = %World
@onready var camera: ShakeCamera2D = %Camera2D
@onready var wind: Wind = %Wind
@onready var music: Music = %Music
@onready var hud_layer: CanvasLayer = %HUDLayer

var game_active: bool:
	set(value):
		game_active = value
		self.world.visible = self.game_active
		self.hud_layer.visible = self.game_active
		self.get_tree().paused = not self.game_active

var ships_alive: int

func spawn_ship(details: PlayerDetails) -> void:
	var ship: Ship = self.SHIP_SCENE.instantiate()
	ship.cannon_fired.connect(self.music._on_ship_cannon_fired)
	ship.damage_taken.connect(self.camera._on_ship_damage_taken)
	ship.destroyed.connect(self._on_ship_destroyed)
	self.world.add_child(ship)
	ship.player = details.player
	ship.nickname = details.nickname
	# TODO let player choose texture, or choose based on index
	ship.texture = self.SHIP_TEXTURES[0]
	# TODO spawn at random safe location
	ship.position.x += randf() * 64
	ship.position.y += randf() * 64
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
