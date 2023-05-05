extends Node

@onready var world: Node2D = %World
@onready var hud_layer: CanvasLayer = %HUDLayer

var game_active: bool:
	set(value):
		game_active = value
		self.world.visible = self.game_active
		self.hud_layer.visible = self.game_active
		self.get_tree().paused = not self.game_active


func _ready() -> void:
	self.game_active = false


func _on_customization_menu_players_ready() -> void:
	self.game_active = true


func _on_game_restarted() -> void:
	self.get_tree().reload_current_scene()
