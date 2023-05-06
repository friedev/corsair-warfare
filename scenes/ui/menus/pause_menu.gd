extends MarginContainer

signal game_restarted

var can_pause := false


func set_paused(paused: bool) -> void:
	if self.can_pause:
		self.get_tree().paused = paused
		self.visible = paused


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_released("pause"):
		self.set_paused(not self.get_tree().paused)


func _on_resume_button_pressed() -> void:
	self.set_paused(not self.get_tree().paused)


func _on_menu_button_pressed() -> void:
	self.set_paused(false)
	self.game_restarted.emit()


func _on_lobby_menu_players_ready() -> void:
	self.can_pause = true


func _on_main_game_over() -> void:
	self.can_pause = false
