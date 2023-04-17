extends MarginContainer

signal game_restarted

@onready var label: Label = %Label


func _on_ship_destroyed(ship: Ship) -> void:
	if not self.visible:
		self.show()
		self.label.text = "Ship %d Wins!" % ship.player


func _on_restart_button_pressed() -> void:
	self.game_restarted.emit()


func _on_quit_button_pressed() -> void:
	self.get_tree().quit()
