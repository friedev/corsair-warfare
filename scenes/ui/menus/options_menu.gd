extends Menu

const CONFIG_PATH := "user://options.cfg"
const OPTIONS_SECTION := "options"
const OPTIONS_GROUP := &"options"


func load_config() -> bool:
	var config := ConfigFile.new()
	var err := config.load(CONFIG_PATH)
	if err != OK:
		return false
	for option_node in get_tree().get_nodes_in_group(OPTIONS_GROUP):
		var option := option_node as Option
		if config.has_section_key(OPTIONS_SECTION, option.key):
			option.set_option(
				config.get_value(OPTIONS_SECTION, option.key),
				false,
			)
	return true


func save_config() -> bool:
	var config := ConfigFile.new()
	for option_node in get_tree().get_nodes_in_group(OPTIONS_GROUP):
		var option := option_node as Option
		config.set_value(OPTIONS_SECTION, option.key, option.get_option())
	return config.save(CONFIG_PATH) == OK


func _ready() -> void:
	var loaded := load_config()
	if not loaded:
		save_config()


func close() -> void:
	save_config()
	super.close()


func _on_save_button_pressed() -> void:
	close()


func _on_cancel_button_pressed() -> void:
	load_config()
	close()
