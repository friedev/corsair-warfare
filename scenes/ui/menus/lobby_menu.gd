extends Control
class_name LobbyMenu

signal players_ready
signal go_back

const PLAYER_SECTION_SCENE := preload("res://scenes/ui/menus/player_section.tscn")

var index := 1
var player_count := 0:
	set(value):
		player_count = value
		self.update_play_button()

@onready var player_section_container := %PlayerSectionContainer as Control
@onready var play_button := %PlayButton as Button
@onready var game_mode_option_button := %GameModeOptionButton as OptionButton
@onready var time_limit_spin_box := %TimeLimitSpinBox as SpinBox
@onready var max_points_spin_box := %MaxPointsSpinBox as SpinBox

# default_focus is intentionally omitted because it would cause unintentional UI
# interaction as players join with their controllers


func add_player_section() -> void:
	var new_section: PlayerSection = self.PLAYER_SECTION_SCENE.instantiate()
	new_section.index = self.index
	new_section.name += str(new_section.index)
	self.index += 1
	new_section.player_set.connect(self._on_player_section_player_set)
	new_section.player_left.connect(self._on_player_section_player_left)
	new_section.customization_updated.connect(self._on_player_section_customization_updated)
	self.player_section_container.add_child(new_section)
	new_section.show()


func is_ready() -> bool:
	if self.player_count == 0:
		return false
	for player_section_node in self.player_section_container.get_children():
		var player_section := player_section_node as PlayerSection
		if not player_section.customization_section.is_valid():
			return false
	return true


func update_play_button() -> void:
	self.play_button.disabled = not self.is_ready()


func _ready() -> void:
	self.game_mode_option_button.selected = Globals.game_mode
	self.time_limit_spin_box.value = Globals.time_limit_seconds
	self.max_points_spin_box.value = Globals.max_points
	self.add_player_section()


func _on_menu_open() -> void:
	self.show()


func _on_back_button_pressed() -> void:
	self.go_back.emit()
	self.hide()


func _on_play_button_pressed() -> void:
	var index := 1
	for details_resource in Globals.players.values():
		var details := details_resource as PlayerDetails
		if details.nickname == "":
			details.nickname = "Player %d" % index
		index += 1
	self.players_ready.emit()
	self.hide()


func _on_player_section_player_set(player: int) -> void:
	if player != Globals.NO_PLAYER:
		self.add_player_section()
		self.player_count += 1


func _on_player_section_player_left(player: int) -> void:
	self.player_count -= 1


func _on_player_section_customization_updated() -> void:
	self.update_play_button()


func _on_time_limit_spin_box_value_changed(value: float) -> void:
	Globals.time_limit_seconds = int(value)


func _on_option_button_item_selected(index: int) -> void:
	Globals.game_mode = index


func _on_max_points_spin_box_value_changed(value: float) -> void:
	Globals.max_points = int(value)
	for player_section_node in self.player_section_container.get_children():
		var player_section := player_section_node as PlayerSection
		player_section.customization_section.update_levels()
