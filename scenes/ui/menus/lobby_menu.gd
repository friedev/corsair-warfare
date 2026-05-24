extends Menu

signal play_pressed(previous: Menu)

const PLAYER_SECTION_SCENE := preload("res://scenes/ui/menus/player_section.tscn")

# default_focus is intentionally omitted because it would cause unintentional UI
# interaction as players join with their controllers

var index := 0
var player_count := 0:
	set(value):
		player_count = value
		update_play_button()

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
	var new_section: PlayerSection = PLAYER_SECTION_SCENE.instantiate()
	new_section.index = index
	new_section.name += str(new_section.index)
	index += 1
	new_section.player_set.connect(_on_player_section_player_set)
	new_section.player_left.connect(_on_player_section_player_left)
	new_section.customization_updated.connect(_on_player_section_customization_updated)
	player_section_container.add_child(new_section)
	new_section.show()


func is_ready() -> bool:
	if player_count == 0:
		return false
	for player_section_node in player_section_container.get_children():
		var player_section := player_section_node as PlayerSection
		if not player_section.is_valid():
			return false
	return true


func update_play_button() -> void:
	play_button.disabled = not is_ready()


func update_deathmatch_options_visibility() -> void:
	deathmatch_options_container.visible = Globals.game_mode == Globals.GameMode.DEATHMATCH


func _ready() -> void:
	game_mode_option_button.selected = Globals.game_mode
	time_limit_spin_box.value = Globals.time_limit_seconds
	max_points_spin_box.value = Globals.max_points
	score_limit_spin_box.value = Globals.score_limit
	kill_score_spin_box.value = Globals.deathmatch_kill_score
	death_score_spin_box.value = Globals.deathmatch_death_score
	self_destruct_score_spin_box.value = Globals.deathmatch_self_destruct_score
	update_deathmatch_options_visibility()
	add_player_section()


func _on_play_button_pressed() -> void:
	var i := 1
	for details_resource in Globals.players.values():
		var details := details_resource as PlayerDetails
		if details.nickname == "":
			details.nickname = "Player %d" % i
		i += 1
	play_pressed.emit(self)
	hide()


func _on_player_section_player_set(player: int) -> void:
	if player != Globals.NO_PLAYER:
		add_player_section()
		player_count += 1


func _on_player_section_player_left(player: int) -> void:
	player_count -= 1


func _on_player_section_customization_updated() -> void:
	update_play_button()


func _on_game_mode_option_button_item_selected(game_mode_index: int) -> void:
	Globals.game_mode = game_mode_index
	update_deathmatch_options_visibility()


func _on_time_limit_spin_box_value_changed(value: float) -> void:
	Globals.time_limit_seconds = int(value)


func _on_score_limit_spin_box_value_changed(value: float) -> void:
	Globals.score_limit = int(value)


func _on_max_points_spin_box_value_changed(value: float) -> void:
	Globals.max_points = int(value)
	for player_section_node in player_section_container.get_children():
		var player_section := player_section_node as PlayerSection
		player_section.update_levels()


func _on_kill_score_spin_box_value_changed(value: float) -> void:
	Globals.deathmatch_kill_score = int(value)


func _on_death_score_spin_box_value_changed(value: float) -> void:
	Globals.deathmatch_death_score = int(value)


func _on_self_destruct_score_spin_box_value_changed(value: float) -> void:
	Globals.deathmatch_self_destruct_score = int(value)
