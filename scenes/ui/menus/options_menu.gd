extends Control

signal go_back


const CONFIG_PATH := "user://options.cfg"
const OPTIONS_SECTION := "options"
const OPTIONS_GROUP := &"options"

@export var default_focus: Control


func load_config() -> bool:
	var config := ConfigFile.new()
	var err := config.load(self.CONFIG_PATH)
	if err != OK:
		return false
	for option_node in self.get_tree().get_nodes_in_group(self.OPTIONS_GROUP):
		var option := option_node as Option
		if config.has_section_key(self.OPTIONS_SECTION, option.key):
			option.set_option(
				config.get_value(self.OPTIONS_SECTION, option.key), false
			)
	return true


func save_config() -> bool:
	var config := ConfigFile.new()
	for option_node in self.get_tree().get_nodes_in_group(self.OPTIONS_GROUP):
		var option := option_node as Option
		config.set_value(self.OPTIONS_SECTION, option.key, option.get_option())
	return config.save(self.CONFIG_PATH) == OK


func _ready() -> void:
	var loaded := self.load_config()
	if not loaded:
		self.save_config()


func _on_menu_open() -> void:
	self.show()
	self.default_focus.grab_focus()


func _on_save_button_pressed() -> void:
	self.save_config()
	self.go_back.emit()
	self.hide()


func _on_cancel_button_pressed() -> void:
	self.load_config()
	self.go_back.emit()
	self.hide()
