class_name Music extends Node

@export var music_timer: Timer


func _on_ship_cannon_fired() -> void:
	self.music_timer.start()


func _on_ship_damage_taken(_damage: float) -> void:
	self.music_timer.start()
