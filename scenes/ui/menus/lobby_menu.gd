extends Control
class_name CustomizationMenu

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


func add_player_section() -> void:
	var new_section: PlayerSection = self.PLAYER_SECTION_SCENE.instantiate()
	new_section.index = self.index
	new_section.name += str(new_section.index)
	self.index += 1
	new_section.player_set.connect(self._on_player_section_player_set)
	new_section.player_left.connect(self._on_player_section_player_left)
	self.player_section_container.add_child(new_section)
	new_section.show()


func update_play_button() -> void:
	self.play_button.disabled = self.player_count == 0


func _ready() -> void:
	self.add_player_section()


func _on_menu_open() -> void:
	self.show()


func _on_back_button_pressed() -> void:
	self.go_back.emit()
	self.hide()


func _on_play_button_pressed() -> void:
	var index := 1
	for details in Globals.players.values():
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
