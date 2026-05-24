extends Menu

signal menu_pressed(previous: Menu)
signal options_pressed(previous: Menu)

var can_pause := false


func set_paused(paused: bool) -> void:
	if not can_pause or paused == visible:
		return
	get_tree().paused = paused
	if paused:
		open()
	else:
		close()


func _input(event: InputEvent) -> void:
	if event.is_action_released(&"pause"):
		set_paused(not get_tree().paused)


func _on_resume_button_pressed() -> void:
	set_paused(false)


func _on_menu_button_pressed() -> void:
	set_paused(false)
	can_pause = false
	menu_pressed.emit(self)


func _on_lobby_menu_play_pressed(_previous: Menu = null) -> void:
	can_pause = true


func _on_main_game_over() -> void:
	can_pause = false


func _notification(what: int) -> void:
	if what == NOTIFICATION_WM_WINDOW_FOCUS_OUT:
		set_paused(true)


func _on_options_button_pressed() -> void:
	hide()
	options_pressed.emit(self)
