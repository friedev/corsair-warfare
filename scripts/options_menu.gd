extends MarginContainer

signal screen_shake_toggled(enabled: bool)
signal go_back


func _on_back_button_pressed() -> void:
	self.go_back.emit()
	self.hide()


func set_volume(bus_name: String, value: float) -> void:
	var bus_index := AudioServer.get_bus_index(bus_name)
	var volume_db := (value - 5) * 3
	AudioServer.set_bus_volume_db(bus_index, volume_db)
	AudioServer.set_bus_mute(bus_index, value == 0)


func _on_sound_slider_value_changed(value: float) -> void:
	self.set_volume("Sound", value)


func _on_music_slider_value_changed(value: float) -> void:
	self.set_volume("Music", value)


func _on_ambience_slider_value_changed(value: float) -> void:
	self.set_volume("Ambience", value)


func _on_menu_open() -> void:
	self.show()


func _on_fullscreen_check_box_toggled(button_pressed: bool) -> void:
	DisplayServer.window_set_mode(
		DisplayServer.WINDOW_MODE_FULLSCREEN
		if button_pressed
		else DisplayServer.WINDOW_MODE_WINDOWED
	)


func _on_screen_shake_check_box_toggled(button_pressed: bool) -> void:
	self.screen_shake_toggled.emit(button_pressed)
