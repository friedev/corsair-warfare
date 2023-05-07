extends Control

signal game_started
signal options
signal credits_button_pressed

@export var default_focus: Control

@onready var quit_button := %QuitButton as Button


func open_menu() -> void:
	self.show()
	self.default_focus.grab_focus()


func _ready() -> void:
	self.quit_button.visible = OS.get_name() != "Web"
	self.open_menu()


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
	self.open_menu()

