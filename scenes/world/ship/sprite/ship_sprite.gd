# Used for both Sprite2Ds and TextureRects
extends Node
class_name ShipSprite

@onready var base_hull := $BaseHull
@onready var base_sails := $BaseSails


func apply_style(style: ShipStyle) -> void:
	self.base_hull.texture = style.base_hull
	self.base_sails.texture = style.base_sails
	# TODO DRY
	for level in range(len(style.hull_levels)):
		self.get_node("Hull%d" % (level + 1)).texture = style.hull_levels[level]
	for level in range(len(style.cannons_levels)):
		self.get_node("Cannons%d" % (level + 1)).texture = style.cannons_levels[level]
	for level in range(len(style.sails_levels)):
		self.get_node("Sails%d" % (level + 1)).texture = style.sails_levels[level]


func apply_levels(levels: Dictionary) -> void:
	for child in self.get_children():
		child.hide()
	self.base_hull.show()
	self.base_sails.show()
	# TODO make this less fragile
	for component in levels:
		for level in range(levels[component]):
			self.get_node("%s%d" % [component, level + 1]).show()
