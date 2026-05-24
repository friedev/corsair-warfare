extends Node

const CONFIG_PATH := "user://options.cfg"
const OPTIONS_SECTION := "options"
const OPTIONS_GROUP := &"options"


func load_config():
	var config := ConfigFile.new()
	config.load(CONFIG_PATH)
	for option_node in get_tree().get_nodes_in_group(OPTIONS_GROUP):
		var option := option_node as Option
		if config.has_section_key(OPTIONS_SECTION, option.key):
			option.set_option(
				config.get_value(OPTIONS_SECTION, option.key), false
			)


func save_config():
	var config := ConfigFile.new()
	for option_node in get_tree().get_nodes_in_group(OPTIONS_GROUP):
		var option := option_node as Option
		config.set_value(OPTIONS_SECTION, option.key, option.get_option())
	config.save(CONFIG_PATH)


func _ready() -> void:
	load_config()


func _on_option_changed(value) -> void:
	save_config()
