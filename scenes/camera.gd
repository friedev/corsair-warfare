class_name ShakeCamera2D extends Camera2D

## Portion of the viewport dedicated to the ships. The remainder is a margin.
@export var content_to_margin_ratio: float

@export var zoom_speed: float

@export var shake_rate: float
@export var max_offset: float
@export var shake_reduction: float

@export var shake_per_damage: float
@export var cannon_shake: float

var shake := 0.0:
	set(value):
		shake = clamp(value, 0.0, 1.0)
var noise := FastNoiseLite.new()

@onready var default_zoom := self.zoom


func _ready() -> void:
	self.noise.seed = randi()


func apply_shake() -> void:
	var noise_position := Time.get_ticks_msec() * self.shake_rate
	var x := self.noise.get_noise_1d(noise_position)
	var y := self.noise.get_noise_1d(-noise_position)
	var max_offset: float = self.max_offset * Globals.options.get("screen_shake_amount", 0.5)
	self.offset = Vector2(x, y) * max_offset * (self.shake ** 2)
	self.shake -= self.shake_reduction


func center_on_ships() -> void:
	var ships := self.get_tree().get_nodes_in_group(&"ships")

	if len(ships) == 0:
		self.global_position = Vector2(0, 0)
		self.zoom = lerp(self.get_zoom(), self.default_zoom, self.zoom_speed)
		return

	# Find bounding box for all ships
	var rect := Rect2()
	var empty_rect := Rect2()
	for ship in ships:
		# Expanding a raw Rect2 causes it to keep (0, 0) as one of its bounding
		# points. Instead of expanding the first time, move to the first point.
		if rect == empty_rect:
			rect.position = ship.global_position
		else:
			rect = rect.expand((ship as Ship).global_position)

	# Center on the bounding box
	self.global_position = rect.get_center()

	# Zoom to fit the bounding box
	var dimensions := self.get_viewport_rect().size
	var screen_ratio := dimensions.x / dimensions.y
	var min_dimensions := dimensions * self.content_to_margin_ratio
	var distance := rect.size.abs()
	var zoom_amount: float = min(
		1.0,
		min_dimensions.x / distance.x,
		min_dimensions.y / distance.y
	)
	var new_zoom := Vector2(zoom_amount, zoom_amount)

	self.zoom = lerp(self.get_zoom(), new_zoom, self.zoom_speed)


func _process(delta: float) -> void:
	self.center_on_ships()
	self.apply_shake()


func _on_ship_damage_taken(damage: float) -> void:
	self.shake = max(self.shake, damage * self.shake_per_damage)


func _on_ship_cannon_fired() -> void:
	self.shake = max(self.shake, self.cannon_shake)
