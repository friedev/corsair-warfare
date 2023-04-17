extends Area2D
class_name WindArea

signal wind_changed(wind: Vector2)

@export var ship1: Ship
@export var ship2: Ship
@export var change_rate: float
@export var noise_multiplier: float
@export var initial_noise_position: float

var wind: Vector2:
	set(value):
		wind = value
		self.set_gravity_direction(self.wind)
		self.wind_changed.emit(self.wind)

var noise_x := FastNoiseLite.new()
var noise_y := FastNoiseLite.new()
var noise_position: float

@onready var collision_shape: CollisionShape2D = %CollisionShape2D


func _ready() -> void:
	var seed := int(Time.get_unix_time_from_system())
	self.noise_x.seed = seed
	self.noise_y.seed = seed + 1
	self.noise_position = self.initial_noise_position


func _physics_process(delta: float) -> void:
	self.noise_position += delta * self.change_rate
	self.wind = Vector2(
		self.noise_x.get_noise_1d(self.noise_position) * self.noise_multiplier,
		self.noise_y.get_noise_1d(self.noise_position) * self.noise_multiplier
	).limit_length()

	if self.wind.x != 0:
		if ship1.linear_velocity.y > 16:
			ship1.correctNYMovement(self.wind.x)
		if ship1.linear_velocity.y < -16:
			ship1.correctYMovement(self.wind.x)

	if self.wind.y != 0:
		if ship1.linear_velocity.x < -16 || ship1.linear_velocity.x > 16:
			ship1.correctNXMovement(self.wind.y)
