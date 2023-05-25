extends Menu

signal menu_pressed(previous: Menu)
signal options_pressed(previous: Menu)

var can_pause := false


func set_paused(paused: bool) -> void:
	if not self.can_pause or paused == self.visible:
		return
	self.get_tree().paused = paused
	if paused:
		self.open()
	else:
		self.close()


func _input(event: InputEvent) -> void:
	if event.is_action_released(&"pause"):
		self.set_paused(not self.get_tree().paused)


func _on_resume_button_pressed() -> void:
	self.set_paused(false)


func _on_menu_button_pressed() -> void:
	self.set_paused(false)
	self.can_pause = false
	self.menu_pressed.emit(self)


func _on_lobby_menu_play_pressed(_previous: Menu = null) -> void:
	self.can_pause = true


func _on_main_game_over() -> void:
	self.can_pause = false


func _notification(what: int) -> void:
	if what == NOTIFICATION_WM_WINDOW_FOCUS_OUT:
		self.set_paused(true)


func _on_options_button_pressed() -> void:
	self.hide()
	self.options_pressed.emit(self)
