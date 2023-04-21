extends Camera2D

@export var ship1: Node2D
@export var ship2: Node2D

@export var shake_rate: float
@export var shake_per_damage: float
@export var max_offset: float
@export var shake_reduction: float

var shake := 0.0:
	set(value):
		shake = clamp(value, 0.0, 1.0)
var noise := FastNoiseLite.new()


func _ready() -> void:
	self.noise.seed = randi()


func apply_shake() -> void:
	var noise_position := Time.get_ticks_msec() * self.shake_rate
	self.offset = Vector2(
		self.noise.get_noise_1d(noise_position),
		self.noise.get_noise_1d(-noise_position)
	) * self.max_offset * (self.shake * self.shake)
	self.shake -= self.shake_reduction


func center_on_ships() -> void:
	self.position.x = (ship1.position.x + ship2.position.x) * 0.5
	self.position.y = (ship1.position.y + ship2.position.y) * 0.5

	var dimensions := self.get_viewport_rect().size

	var screen_width := dimensions.x
	var screen_height := dimensions.y
	var screen_ratio := screen_width / screen_height

	var x_min := screen_width * 0.75
	var y_min := screen_height * 0.75
	var dist := ship2.position - ship1.position
	var x_dist: float = abs(dist.x)
	var y_dist: float = abs(dist.y)

	var zoom_val := self.get_zoom()

	if x_dist > screen_ratio * y_dist and x_dist > x_min:
		zoom_val = Vector2(x_min / x_dist, x_min / x_dist)
	if screen_ratio * y_dist > x_dist and y_dist > y_min:
		zoom_val = Vector2(y_min / y_dist, y_min / y_dist)

	self.set_zoom(self.get_zoom().lerp(zoom_val, 0.05))


func _process(delta: float) -> void:
	self.center_on_ships()
	self.apply_shake()


func _on_ship_damage_taken(damage: float) -> void:
	self.shake = max(self.shake, damage * shake_per_damage)
