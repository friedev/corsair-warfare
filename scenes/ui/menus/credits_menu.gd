extends Control

signal back_button_pressed

@export var default_focus: Control


func _on_back_button_pressed() -> void:
	self.back_button_pressed.emit()
	self.hide()


func _on_menu_open() -> void:
	self.show()
	self.default_focus.grab_focus()
