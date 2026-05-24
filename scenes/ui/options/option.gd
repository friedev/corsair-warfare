class_name Option extends Control

signal changed(value)

@export var key: String


func _ready() -> void:
	if key in Options.options:
		set_option(get_default(), false)


func get_option():
	return Globals.options[key]


func set_option(value, emit := true) -> void:
	Globals.options[key] = value
	if emit:
		changed.emit(value)


func get_default():
	assert(false, "Abstract function called")
