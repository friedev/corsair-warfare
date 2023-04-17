extends Node

@onready var ship1: Ship = %Ship1
@onready var ship2: Ship = %Ship2
@onready var wind_area: WindArea = %WindArea


func _ready() -> void:
	self.ship1.set_enabled(false)
	self.ship2.set_enabled(false)
	self.wind_area.collision_shape.disabled = true


func _on_customization_menu_players_ready() -> void:
	self.ship1.set_enabled(true)
	self.ship2.set_enabled(true)
	self.wind_area.collision_shape.disabled = false
