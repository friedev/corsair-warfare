extends Node

@onready var world: Node2D = %World
@onready var ship1: Ship = %Ship1
@onready var ship2: Ship = %Ship2
@onready var wind: Wind = %Wind
@onready var wind_particles: GPUParticles2D = %WindParticles
@onready var wind_hud: Control = %WindHUD

var game_active: bool:
	set(value):
		game_active = value
		self.world.visible = self.game_active
		self.ship1.enabled = self.game_active
		self.ship2.enabled = self.game_active
		self.wind.enabled = self.game_active
		self.wind_particles.emitting = self.game_active
		self.wind_hud.visible = self.game_active


func _ready() -> void:
	self.game_active = false


func _on_customization_menu_players_ready() -> void:
	self.game_active = true


func _on_game_restarted() -> void:
	self.get_tree().reload_current_scene()
