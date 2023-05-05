extends MarginContainer

signal back_button_pressed


func _on_back_button_pressed() -> void:
	self.back_button_pressed.emit()
	self.hide()


func _on_menu_open() -> void:
	self.show()
