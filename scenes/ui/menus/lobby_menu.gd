extends Menu

signal play_pressed(previous: Menu)

const PLAYER_SECTION_SCENE := preload("res://scenes/ui/menus/player_section.tscn")

# default_focus is intentionally omitted because it would cause unintentional UI
# interaction as players join with their controllers

var index := 0
var player_count := 0:
	set(value):
		player_count = value
		self.update_play_button()

@export var player_section_container: Control
@export var play_button: Button
@export var game_mode_option_button: OptionButton
@export var time_limit_spin_box: SpinBox
@export var max_points_spin_box: SpinBox
@export var deathmatch_options_container: Control
@export var score_limit_spin_box: SpinBox
@export var kill_score_spin_box: SpinBox
@export var death_score_spin_box: SpinBox
@export var self_destruct_score_spin_box: SpinBox


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
		if not player_section.is_valid():
			return false
	return true


func update_play_button() -> void:
	self.play_button.disabled = not self.is_ready()


func update_deathmatch_options_visibility() -> void:
	self.deathmatch_options_container.visible = Globals.game_mode == Globals.GameMode.DEATHMATCH


func _ready() -> void:
	self.game_mode_option_button.selected = Globals.game_mode
	self.time_limit_spin_box.value = Globals.time_limit_seconds
	self.max_points_spin_box.value = Globals.max_points
	self.score_limit_spin_box.value = Globals.score_limit
	self.kill_score_spin_box.value = Globals.deathmatch_kill_score
	self.death_score_spin_box.value = Globals.deathmatch_death_score
	self.self_destruct_score_spin_box.value = Globals.deathmatch_self_destruct_score
	self.update_deathmatch_options_visibility()
	self.add_player_section()


func _on_play_button_pressed() -> void:
	var index := 1
	for details_resource in Globals.players.values():
		var details := details_resource as PlayerDetails
		if details.nickname == "":
			details.nickname = "Player %d" % index
		index += 1
	self.play_pressed.emit(self)
	self.hide()


func _on_player_section_player_set(player: int) -> void:
	if player != Globals.NO_PLAYER:
		self.add_player_section()
		self.player_count += 1


func _on_player_section_player_left(player: int) -> void:
	self.player_count -= 1


func _on_player_section_customization_updated() -> void:
	self.update_play_button()


func _on_game_mode_option_button_item_selected(index: int) -> void:
	Globals.game_mode = index
	self.update_deathmatch_options_visibility()


func _on_time_limit_spin_box_value_changed(value: float) -> void:
	Globals.time_limit_seconds = int(value)


func _on_score_limit_spin_box_value_changed(value: float) -> void:
	Globals.score_limit = int(value)


func _on_max_points_spin_box_value_changed(value: float) -> void:
	Globals.max_points = int(value)
	for player_section_node in self.player_section_container.get_children():
		var player_section := player_section_node as PlayerSection
		player_section.update_levels()


func _on_kill_score_spin_box_value_changed(value: float) -> void:
	Globals.deathmatch_kill_score = int(value)


func _on_death_score_spin_box_value_changed(value: float) -> void:
	Globals.deathmatch_death_score = int(value)


func _on_self_destruct_score_spin_box_value_changed(value: float) -> void:
	Globals.deathmatch_self_destruct_score = int(value)
