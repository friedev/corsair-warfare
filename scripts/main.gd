extends Node

@onready var ship1: Ship = %Ship1
@onready var ship2: Ship = %Ship2


func set_ship_enabled(ship: Ship, enabled: bool) -> void:
	ship.visible = enabled
	ship.set_process(enabled)
	ship.set_physics_process(enabled)
	ship.set_process_input(enabled)


func _ready() -> void:
	self.set_ship_enabled(self.ship1, false)
	self.set_ship_enabled(self.ship2, false)


func _on_customization_menu_players_ready() -> void:
	self.set_ship_enabled(self.ship1, true)
	self.set_ship_enabled(self.ship2, true)
