extends AudioStreamPlayer

@export var wind: Wind
@export var min_volume_db: float
@export var max_volume_db: float

func _process(delta: float) -> void:
	if self.wind.enabled != self.playing:
		self.playing = self.wind.enabled
	self.volume_db = (
		min_volume_db
		+ (max_volume_db - min_volume_db) * self.wind.wind.length()
	)
