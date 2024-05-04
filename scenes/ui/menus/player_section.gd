class_name PlayerSection extends Control

signal player_set(player: int)
signal player_left(player: int)
signal customization_updated

@export var styles: Array[ShipStyle]

var index: int

var details := PlayerDetails.new()

var player := Globals.NO_PLAYER:
	set(value):
		if value != Globals.NO_PLAYER and value in Globals.players:
			return
		self.set_controls_visible(false)
		player = value
		self.details.player = self.player
		self.set_controls_visible(true)
		self.updated_joined_containers()
		Globals.register_player(self.player, self.details)
		self.player_set.emit(self.player)

var style_index: int:
	set(value):
		style_index = wrapi(value, 0, len(self.styles))
		self.texture_rect.apply_style(self.get_style())
		self.details.style = self.get_style()

@export var joined_container: Control
@export var not_joined_container: Control

@export var keyboard_1_button: Button
@export var keyboard_2_button: Button

@export var controls_container: Control
@export var keyboard_1_controls: Control
@export var keyboard_2_controls: Control
@export var joy_controls: Control

@export var texture_rect: ShipSprite
@export var points_label: Label

# TODO DRY
@export var hull_slider: Slider
@export var sails_slider: Slider
@export var cannons_slider: Slider
@onready var sliders: Array[Slider] = [
	self.hull_slider,
	self.sails_slider,
	self.cannons_slider
]


func get_style() -> ShipStyle:
	return self.styles[self.style_index]


func is_valid() -> bool:
	return self.get_points_spent() <= Globals.max_points


func get_points_spent() -> int:
	var points_spent := 0
	for slider in self.sliders:
		points_spent += slider.value
	return points_spent


func get_levels() -> Dictionary:
	# TODO DRY
	return {
		"Hull": self.hull_slider.value,
		"Cannons": self.cannons_slider.value,
		"Sails": self.sails_slider.value,
	}


func update_levels() -> void:
	var points_spent := self.get_points_spent()
	self.points_label.text = "%d/%d Points Spent" % [points_spent, Globals.max_points]
	self.points_label.modulate = (
		Color.WHITE
		if points_spent <= Globals.max_points
		else Color(1, 0.25, 0.25)
	)
	self.texture_rect.apply_levels(self.get_levels())
	self.details.levels = self.get_levels()
	self.customization_updated.emit()


func _on_slider_value_changed(_value: float) -> void:
	self.update_levels()


func _on_previous_style_button_pressed() -> void:
	self.style_index -= 1


func _on_next_style_button_pressed() -> void:
	self.style_index += 1


func get_controls() -> Control:
	match self.player:
		Globals.KEYBOARD_1_PLAYER:
			return self.keyboard_1_controls
		Globals.KEYBOARD_2_PLAYER:
			return self.keyboard_2_controls
		Globals.NO_PLAYER:
			return null
		_:
			return self.joy_controls


func set_controls_visible(visible: bool) -> void:
	var my_controls := self.get_controls()
	for controls in self.controls_container.get_children():
		controls.visible = controls == my_controls


func updated_joined_containers() -> void:
	var joined := self.player != Globals.NO_PLAYER
	self.not_joined_container.visible = not joined
	self.joined_container.visible = joined


func leave() -> void:
	Globals.deregister_player(self.player)
	self.player_left.emit(self.player)
	self.queue_free()


func update_keyboard_buttons() -> void:
	self.keyboard_1_button.disabled = Globals.KEYBOARD_1_PLAYER in Globals.players
	self.keyboard_2_button.disabled = Globals.KEYBOARD_2_PLAYER in Globals.players


func _ready() -> void:
	self.update_keyboard_buttons()

	Globals.player_registered.connect(self._on_player_registered)
	Globals.player_deregistered.connect(self._on_player_deregistered)

	self.style_index = self.index
	self.update_levels()


func _unhandled_input(event: InputEvent) -> void:
	if (
		not self.is_visible_in_tree()
		or not event.is_pressed()
		or not event is InputEventJoypadButton
	):
		return

	var joy_event := event as InputEventJoypadButton

	if self.player == Globals.NO_PLAYER and joy_event.button_index == JOY_BUTTON_A:
		self.player = joy_event.device
		return

	if self.player == joy_event.device and joy_event.button_index == JOY_BUTTON_B:
		self.leave()
		return


func _on_nickname_edit_text_changed(new_text: String) -> void:
	self.details.nickname = new_text


func _on_leave_button_pressed() -> void:
	self.leave()


func _on_keyboard_1_button_pressed() -> void:
	self.player = Globals.KEYBOARD_1_PLAYER


func _on_keyboard_2_button_pressed() -> void:
	self.player = Globals.KEYBOARD_2_PLAYER


func _on_player_registered(player: int) -> void:
	self.update_keyboard_buttons()


func _on_player_deregistered(player: int) -> void:
	self.update_keyboard_buttons()
