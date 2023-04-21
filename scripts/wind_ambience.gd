extends AudioStreamPlayer

@export var min_volume_db: float
@export var max_volume_db: float

func _on_wind_area_wind_changed(wind: Vector2) -> void:
	if not self.playing:
		self.play()
	self.volume_db = min_volume_db + (max_volume_db - min_volume_db) * wind.length()
