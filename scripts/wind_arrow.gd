extends NinePatchRect


@export var minimum_size: int
@export var maximum_size: int


func _on_wind_area_wind_changed(wind: Vector2) -> void:
	self.rotation = wind.angle()
	self.size.x = wind.length() * (maximum_size - minimum_size) + minimum_size
