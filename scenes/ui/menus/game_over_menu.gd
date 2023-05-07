extends Control

signal game_restarted

@export var default_focus: Control

@onready var label: Label = %Label


func _on_menu_button_pressed() -> void:
	self.game_restarted.emit()
	self.hide()


func _on_main_game_over() -> void:
	if self.visible:
		return
	self.label.text = "Game Over"
	var max_health := 0.0
	if Globals.game_mode == Globals.GameMode.LAST_MAN_STANDING:
		for ship in self.get_tree().get_nodes_in_group(&"ships"):
			if ship.health > max_health:
				self.label.text = "%s Wins" % ship.details.nickname
				max_health = ship.health
			elif ship.health == max_health and max_health > 0.0:
				self.label.text = "Draw"
	elif Globals.game_mode == Globals.GameMode.DEATHMATCH:
		var max_score := -2^63
		for details in Globals.players.values():
			if details.score > max_score:
				self.label.text = "%s Wins" % details.nickname
				max_score = details.score
			elif details.score == max_score:
				self.label.text = "Draw"
	self.show()
	self.default_focus.grab_focus()
