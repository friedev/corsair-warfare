extends Container
class_name CustomizationMenu

signal players_ready

@export var ship1: Ship
@export var ship2: Ship
@export var ship3: Ship

@onready var section1: CustomizationSection = %CustomizationSection1
@onready var section2: CustomizationSection = %CustomizationSection2
@onready var section3: CustomizationSection = %CustomizationSection3

var all_players_ready: Array[bool] = [false, false, false]

var hull_values: Array[float] = [1.0, 1.5, 2.0, 2.5]
var sails_values: Array[float] = [1.0, (4.0 / 3.0), (5.0 / 3.0), 2.0]
var cannons_values: Array[int] = [3, 4, 5, 6]


func apply_customization(ship: Ship, section: CustomizationSection) -> void:
	ship.max_health = self.hull_values[section.hull_slider.value]
	ship.health = ship.max_health
	ship.speed *= self.sails_values[section.sails_slider.value]
	ship.cannon_count = self.cannons_values[section.cannons_slider.value]


func _on_customization_section_1_player_ready() -> void:
	self.all_players_ready[0] = true
	self.apply_customization(self.ship1, self.section1)
	if not false in all_players_ready:
		self.players_ready.emit()
		self.hide()


func _on_customization_section_2_player_ready() -> void:
	print_debug(all_players_ready)
	self.all_players_ready[1] = true
	self.apply_customization(self.ship2, self.section2)
	if not false in all_players_ready:
		self.players_ready.emit()
		self.hide()


func _on_customization_section_3_player_ready() -> void:
	self.all_players_ready[2] = true
	self.apply_customization(self.ship3, self.section3)
	if not false in all_players_ready:
		self.players_ready.emit()
		self.hide()


func _on_main_menu_game_started() -> void:
	self.show()
