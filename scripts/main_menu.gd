extends MarginContainer


signal game_started
signal options
signal credits_button_pressed


func _ready() -> void:
	self.show()


func _on_play_button_pressed() -> void:
	self.game_started.emit()
	self.hide()


func _on_options_button_pressed() -> void:
	self.options.emit()
	self.hide()


func _on_credits_button_pressed() -> void:
	self.credits_button_pressed.emit()
	self.hide()


func _on_quit_button_pressed() -> void:
	self.get_tree().quit()


func _on_menu_open() -> void:
	self.show()
