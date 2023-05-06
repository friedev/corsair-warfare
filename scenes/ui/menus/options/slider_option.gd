extends Option
class_name SliderOption

@export var default: float

@onready var slider: Slider = %Slider


func get_option() -> float:
	return self.check_box.button_pressed


func set_option(value: float, emit := true) -> void:
	self.slider.set_value_no_signal(value)
	super.set_option(value, emit)


func _on_slider_value_changed(value: float) -> void:
	self.set_option(value)
