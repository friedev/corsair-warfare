extends Area2D
class_name WindArea

signal wind_changed(wind: Vector2)

@export var ship1: Ship
@export var ship2: Ship
@export var wind_change_rate: float
@export var wind_noise_multiplier: float
@export var initial_wind_noise_position: float

var wind: Vector2:
	set(value):
		wind = value
		self.set_gravity_direction(self.wind)
		self.wind_changed.emit(self.wind)

var wind_noise_x := FastNoiseLite.new()
var wind_noise_y := FastNoiseLite.new()
var wind_noise_position: float

@onready var collision_shape: CollisionShape2D = %CollisionShape2D


func _ready() -> void:
	var seed := int(Time.get_unix_time_from_system())
	self.wind_noise_x.seed = seed
	self.wind_noise_y.seed = seed + 1
	self.wind_noise_position = self.initial_wind_noise_position


func _physics_process(delta: float) -> void:
	self.wind_noise_position += delta * self.wind_change_rate
	self.wind = Vector2(
		self.wind_noise_x.get_noise_1d(self.wind_noise_position) * self.wind_noise_multiplier,
		self.wind_noise_y.get_noise_1d(self.wind_noise_position) * self.wind_noise_multiplier
	).limit_length()

	if self.wind.x != 0:
		if ship1.linear_velocity.y > 16:
			ship1.correctNYMovement(self.wind.x)
		if ship1.linear_velocity.y < -16:
			ship1.correctYMovement(self.wind.x)

	if self.wind.y != 0:
		if ship1.linear_velocity.x < -16 || ship1.linear_velocity.x > 16:
			ship1.correctNXMovement(self.wind.y)
