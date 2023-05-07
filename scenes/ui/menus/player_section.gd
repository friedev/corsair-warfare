extends Control
class_name PlayerSection

signal player_set(player: int)
signal player_left(player: int)
signal customization_updated

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

@onready var joined_container := %JoinedContainer as Control
@onready var not_joined_container := %NotJoinedContainer as Control

@onready var keyboard_1_button := %Keyboard1Button as Button
@onready var keyboard_2_button := %Keyboard2Button as Button

@onready var customization_section := %CustomizationSection as CustomizationSection

@onready var controls_container := %ControlsContainer as Control
@onready var keyboard_1_controls := %Keyboard1Controls as Control
@onready var keyboard_2_controls := %Keyboard2Controls as Control
@onready var joy_controls := %JoyControls as Control


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

	self.customization_section.update_levels()
	self.customization_section.update_style()

	self.details.levels = self.customization_section.get_levels()
	self.details.style = self.customization_section.get_style()


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


func _on_customization_section_levels_updated() -> void:
	self.details.levels = self.customization_section.get_levels()
	self.customization_updated.emit()


func _on_customization_section_style_updated() -> void:
	self.details.style = self.customization_section.get_style()
