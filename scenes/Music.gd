extends AudioStreamPlayer2D

var music_volume = 0

@onready var music_timer: Timer = %music_timer

@export var phase: int

func _ready():
	print("Linear Volume: ", db_to_linear(volume_db))
	print("DB Volume: ", volume_db)

func _process(delta):
	var volume_linear = db_to_linear(volume_db)
	if music_timer.is_stopped():
		if phase == 1:
			volume_linear = clampf(volume_linear + 0.02, 0, 1)
		if phase == 2:
			volume_linear = clampf(volume_linear - 0.02, 0, 1)
	else:
		if phase == 1:
			volume_linear = clampf(volume_linear - 0.02, 0, 1)
		if phase == 2:
			volume_linear = clampf(volume_linear + 0.02, 0, 1)
	volume_db = linear_to_db(volume_linear)
	#print(volume_linear, "      ", volume_db)

func _on_finished():
	self.playing = true

func _on_music_timer_timeout():
	music_timer.stop()

func _on_ship_cannon_fired():
	music_timer.start()
