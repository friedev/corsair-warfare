extends Control

@export var wind: Wind
@export var minimum_size: int
@export var maximum_size: int

@export var arrow: NinePatchRect


func _process(delta: float) -> void:
	arrow.rotation = wind.wind.angle()
	arrow.size.x = (
		wind.wind.length() * (maximum_size - minimum_size) + minimum_size
	)
