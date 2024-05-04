extends Menu

signal menu_pressed(previous: Menu)

@export var label: Label


func _on_menu_button_pressed() -> void:
	self.hide()
	self.menu_pressed.emit(self)


func get_game_over_text() -> String:
	var text := "Game Over"
	var winner := Globals.get_winner()
	var ships := self.get_tree().get_nodes_in_group(&"ships")
	if winner != null:
		return "%s Wins" % winner.nickname
	elif len(ships) > 1:
		return "Draw"
	else:
		return "Game Over"


func _on_main_game_over() -> void:
	if self.visible:
		return
	self.label.text = self.get_game_over_text()
	self.open()
