extends Control


@export var minimum_size: int
@export var maximum_size: int

@onready var arrow: NinePatchRect = %Arrow

func _on_wind_area_wind_changed(wind: Vector2) -> void:
	self.arrow.rotation = wind.angle()
	self.arrow.size.x = wind.length() * (maximum_size - minimum_size) + minimum_size
