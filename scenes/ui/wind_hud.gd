extends Control

@export var wind: Wind
@export var minimum_size: int
@export var maximum_size: int

@export var arrow: NinePatchRect


func _process(delta: float) -> void:
	self.arrow.rotation = self.wind.wind.angle()
	self.arrow.size.x = (
		self.wind.wind.length() * (maximum_size - minimum_size) + minimum_size
	)
