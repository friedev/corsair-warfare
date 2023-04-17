extends MarginContainer


var can_pause := false


func set_paused(paused: bool) -> void:
	if self.can_pause:
		self.get_tree().paused = paused
		self.visible = paused


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_released("pause"):
		self.set_paused(not self.get_tree().paused)


func _on_resume_button_pressed() -> void:
	self.set_paused(not self.get_tree().paused)


func _on_customization_menu_players_ready() -> void:
	self.can_pause = true


func _on_ship_destroyed(ship: Ship) -> void:
	self.can_pause = false