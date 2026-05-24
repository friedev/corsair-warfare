class_name PlayerSection
extends Control

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
		set_controls_visible(false)
		player = value
		details.player = player
		set_controls_visible(true)
		updated_joined_containers()
		Globals.register_player(player, details)
		player_set.emit(player)

var style_index: int:
	set(value):
		style_index = wrapi(value, 0, len(styles))
		texture_rect.apply_style(get_style())
		details.style = get_style()

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
	hull_slider,
	sails_slider,
	cannons_slider,
]


func get_style() -> ShipStyle:
	return styles[style_index]


func is_valid() -> bool:
	return get_points_spent() <= Globals.max_points


func get_points_spent() -> int:
	var points_spent := 0
	for slider in sliders:
		points_spent += slider.value
	return points_spent


func get_levels() -> Dictionary:
	# TODO DRY
	return {
		"Hull": hull_slider.value,
		"Cannons": cannons_slider.value,
		"Sails": sails_slider.value,
	}


func update_levels() -> void:
	var points_spent := get_points_spent()
	points_label.text = "%d/%d Points Spent" % [points_spent, Globals.max_points]
	points_label.modulate = (
		Color.WHITE
		if points_spent <= Globals.max_points
		else Color(1, 0.25, 0.25)
	)
	texture_rect.apply_levels(get_levels())
	details.levels = get_levels()
	customization_updated.emit()


func _on_slider_value_changed(_value: float) -> void:
	update_levels()


func _on_previous_style_button_pressed() -> void:
	style_index -= 1


func _on_next_style_button_pressed() -> void:
	style_index += 1


func get_controls() -> Control:
	match player:
		Globals.KEYBOARD_1_PLAYER:
			return keyboard_1_controls
		Globals.KEYBOARD_2_PLAYER:
			return keyboard_2_controls
		Globals.NO_PLAYER:
			return null
		_:
			return joy_controls


func set_controls_visible(visible: bool) -> void:
	var my_controls := get_controls()
	for controls in controls_container.get_children():
		controls.visible = controls == my_controls


func updated_joined_containers() -> void:
	var joined := player != Globals.NO_PLAYER
	not_joined_container.visible = not joined
	joined_container.visible = joined


func leave() -> void:
	Globals.deregister_player(player)
	player_left.emit(player)
	queue_free()


func update_keyboard_buttons() -> void:
	keyboard_1_button.disabled = Globals.KEYBOARD_1_PLAYER in Globals.players
	keyboard_2_button.disabled = Globals.KEYBOARD_2_PLAYER in Globals.players


func _ready() -> void:
	update_keyboard_buttons()

	Globals.player_registered.connect(_on_player_registered)
	Globals.player_deregistered.connect(_on_player_deregistered)

	style_index = index
	update_levels()


func _unhandled_input(event: InputEvent) -> void:
	if (
		not is_visible_in_tree()
		or not event.is_pressed()
		or not event is InputEventJoypadButton
	):
		return

	var joy_event := event as InputEventJoypadButton

	if player == Globals.NO_PLAYER and joy_event.button_index == JOY_BUTTON_A:
		player = joy_event.device
		return

	if player == joy_event.device and joy_event.button_index == JOY_BUTTON_B:
		leave()
		return


func _on_nickname_edit_text_changed(new_text: String) -> void:
	details.nickname = new_text


func _on_leave_button_pressed() -> void:
	leave()


func _on_keyboard_1_button_pressed() -> void:
	player = Globals.KEYBOARD_1_PLAYER


func _on_keyboard_2_button_pressed() -> void:
	player = Globals.KEYBOARD_2_PLAYER


func _on_player_registered(player: int) -> void:
	update_keyboard_buttons()


func _on_player_deregistered(player: int) -> void:
	update_keyboard_buttons()
