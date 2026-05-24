# Used for both Sprite2Ds and TextureRects
class_name ShipSprite
extends CanvasItem

@export var base_hull: CanvasItem
@export var base_sails: CanvasItem


func apply_style(style: ShipStyle) -> void:
	base_hull.texture = style.base_hull
	base_sails.texture = style.base_sails
	# TODO DRY
	for level in range(len(style.hull_levels)):
		get_node("Hull%d" % (level + 1)).texture = style.hull_levels[level]
	for level in range(len(style.cannons_levels)):
		get_node("Cannons%d" % (level + 1)).texture = style.cannons_levels[level]
	for level in range(len(style.sails_levels)):
		get_node("Sails%d" % (level + 1)).texture = style.sails_levels[level]


func apply_levels(levels: Dictionary) -> void:
	for child in get_children():
		child.hide()
	base_hull.show()
	base_sails.show()
	# TODO make this less fragile
	for component in levels:
		for level in range(levels[component]):
			get_node("%s%d" % [component, level + 1]).show()
