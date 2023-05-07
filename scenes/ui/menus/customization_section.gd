extends Control
class_name CustomizationSection

signal levels_updated
signal style_updated

@export var max_points: int
@export var styles: Array[ShipStyle]

var style_index := 0

@onready var texture_rect: ShipSprite = %ShipTextureRect
@onready var points_label: Label = %PointsLabel

# TODO DRY
@onready var hull_slider: Slider = %HullSlider
@onready var sails_slider: Slider = %SailsSlider
@onready var cannons_slider: Slider = %CannonsSlider
@onready var sliders: Array[Slider] = [
	self.hull_slider,
	self.sails_slider,
	self.cannons_slider
]


func _ready() -> void:
	self.style_index = self.style_index


func get_style() -> ShipStyle:
	return self.styles[self.style_index]


func get_points_spent() -> int:
	var points_spent := 0
	for slider in self.sliders:
		points_spent += slider.value
	return points_spent


func is_valid() -> bool:
	return self.get_points_spent() <= self.max_points


func get_levels() -> Dictionary:
	# TODO DRY
	return {
		"Hull": self.hull_slider.value,
		"Cannons": self.cannons_slider.value,
		"Sails": self.sails_slider.value,
	}


func update_levels() -> void:
	var points_spent := self.get_points_spent()
	self.points_label.text = "%d/%d Points Spent" % [points_spent, self.max_points]
	self.points_label.modulate = (
		Color.WHITE
		if points_spent <= max_points
		else Color(1, 0.25, 0.25)
	)
	self.texture_rect.apply_levels(self.get_levels())


func _on_slider_value_changed(_value: float) -> void:
	self.update_levels()
	self.levels_updated.emit()


func update_style() -> void:
	self.texture_rect.apply_style(self.get_style())


func _on_previous_style_button_pressed() -> void:
	self.style_index = wrap(self.style_index - 1, 0, len(self.styles))
	self.update_style()
	self.style_updated.emit()


func _on_next_style_button_pressed() -> void:
	self.style_index = wrap(self.style_index + 1, 0, len(self.styles))
	self.update_style()
	self.style_updated.emit()