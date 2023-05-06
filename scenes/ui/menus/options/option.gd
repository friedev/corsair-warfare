extends Control
class_name Option

signal changed(value)

@export var key: String


func _ready() -> void:
	self.set_option(self.default, false)


func get_option():
	return Globals.options[self.key]


func set_option(value, emit := true) -> void:
	Globals.options[self.key] = value
	if emit:
		self.changed.emit(value)
