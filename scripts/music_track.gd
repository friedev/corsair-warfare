extends AudioStreamPlayer2D

@export var play_during_timer: bool
@export var fade_duration: float

@onready var music_timer: Timer = %MusicTimer


func _process(delta: float):
	var volume_linear := db_to_linear(volume_db)
	var increment := delta / self.fade_duration
	if play_during_timer and not music_timer.is_stopped():
		volume_linear += increment
	else:
		volume_linear -= increment
	volume_linear = clampf(volume_linear, 0.0, 1.0)
	self.volume_db = linear_to_db(volume_linear)
