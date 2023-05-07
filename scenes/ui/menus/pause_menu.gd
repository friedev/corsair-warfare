extends Control

signal game_restarted

@export var default_focus: Control

var can_pause := false


func set_paused(paused: bool) -> void:
	if not self.can_pause:
		return
	self.get_tree().paused = paused
	self.visible = paused
	if paused:
		self.default_focus.grab_focus()


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_released("pause"):
		self.set_paused(not self.get_tree().paused)


func _on_resume_button_pressed() -> void:
	self.set_paused(false)


func _on_menu_button_pressed() -> void:
	self.set_paused(false)
	self.can_pause = false
	self.game_restarted.emit()


func _on_lobby_menu_players_ready() -> void:
	self.can_pause = true


func _on_main_game_over() -> void:
	self.can_pause = false
