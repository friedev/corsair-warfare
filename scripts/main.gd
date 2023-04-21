extends Node

@onready var ship1: Ship = %Ship1
@onready var ship2: Ship = %Ship2
@onready var wind_area: WindArea = %WindArea
@onready var wind_particles: GPUParticles2D = %WindParticles
@onready var wind_hud: Control = %WindHUD


func set_game_active(active: bool) -> void:
	self.ship1.set_enabled(active)
	self.ship2.set_enabled(active)
	self.wind_area.set_physics_process(active)
	self.wind_area.collision_shape.disabled = not active
	self.wind_particles.emitting = active
	self.wind_hud.visible = active


func _ready() -> void:
	self.set_game_active(false)


func _on_customization_menu_players_ready() -> void:
	self.set_game_active(true)


func _on_game_over_menu_game_restarted() -> void:
	self.get_tree().reload_current_scene()
