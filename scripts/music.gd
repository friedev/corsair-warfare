extends Node

@onready var music_timer: Timer = %MusicTimer


func _on_ship_cannon_fired() -> void:
	self.music_timer.start()
