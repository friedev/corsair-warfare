extends Container
class_name CustomizationSection

signal player_ready

@export var max_points: int

var is_player_ready := false

@onready var points_label: Label = %PointsLabel
@onready var ready_button: Button = %ReadyButton

# TODO DRY?
@onready var hull_slider: Slider = %HullSlider
@onready var sails_slider: Slider = %SailsSlider
@onready var cannons_slider: Slider = %CannonsSlider
@onready var sliders: Array[Slider] = [
	self.hull_slider,
	self.sails_slider,
	self.cannons_slider
]


func get_points_spent() -> int:
	var points_spent := 0
	for slider in self.sliders:
		points_spent += slider.value
	return points_spent


func refresh() -> void:
	var points_spent := self.get_points_spent()
	self.points_label.text = "%d/%d Points Spent" % [points_spent, self.max_points]
	if points_spent > max_points:
		self.points_label.modulate = Color.RED
		self.ready_button.disabled = true
	else:
		self.points_label.modulate = Color.WHITE
		self.ready_button.disabled = false


func _on_slider_value_changed(_value: float) -> void:
	self.refresh()


func _on_ready_button_pressed() -> void:
	if self.get_points_spent() <= self.max_points:
		self.ready_button.toggle_mode = true
		self.ready_button.button_pressed = true
		self.ready_button.disabled = true
		for slider in self.sliders:
			slider.editable = false
		self.is_player_ready = true
		self.player_ready.emit()


func _ready() -> void:
	self.refresh()
