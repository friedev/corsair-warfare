extends Menu

signal menu_pressed(previous: Menu)

@export var label: Label


func _on_menu_button_pressed() -> void:
	self.hide()
	self.menu_pressed.emit(self)


func get_game_over_text() -> String:
	var max_health_percent := 0.0
	var text := "Game Over"
	if Globals.game_mode == Globals.GameMode.LAST_MAN_STANDING:
		for ship_node in self.get_tree().get_nodes_in_group(&"ships"):
			var ship := ship_node as Ship
			var health_percent := ship.health / ship.max_health
			if health_percent > max_health_percent:
				text = "%s Wins" % ship.details.nickname
				max_health_percent = health_percent
			elif (
				health_percent == max_health_percent
				and max_health_percent > 0.0
			):
				text = "Draw"
	elif Globals.game_mode == Globals.GameMode.DEATHMATCH:
		var max_score := -2^63
		for details in Globals.players.values():
			if details.score > max_score:
				text = "%s Wins" % details.nickname
				max_score = details.score
			elif details.score == max_score:
				text = "Draw"
	return text


func _on_main_game_over() -> void:
	if self.visible:
		return
	self.label.text = self.get_game_over_text()
	self.open()
