extends Container

signal game_restarted

@onready var label: Label = %Label


func _on_menu_button_pressed() -> void:
	self.game_restarted.emit()


func _on_main_game_over() -> void:
	if self.visible:
		return
	self.label.text = "Game Over"
	var max_health := 0.0
	for ship in self.get_tree().get_nodes_in_group(&"ships"):
		if ship.health > max_health:
			self.label.text = "%s Wins" % ship.nickname
			max_health = ship.health
		elif ship.health == max_health and max_health > 0.0:
			self.label.text = "Draw"
	self.show()
