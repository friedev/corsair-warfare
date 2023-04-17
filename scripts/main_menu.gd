extends MarginContainer


signal game_started
signal options


func _ready() -> void:
	self.show()


func _on_play_button_pressed() -> void:
	self.game_started.emit()
	self.hide()


func _on_quit_button_pressed() -> void:
	self.get_tree().quit()


func _on_options_button_pressed() -> void:
	self.options.emit()
	self.hide()


func _on_options_menu_go_back() -> void:
	self.show()
