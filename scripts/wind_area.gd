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
		self.gravity_direction = self.wind
		self.gravity = self.initial_gravity * wind.length()
		self.wind_changed.emit(self.wind)

var noise := FastNoiseLite.new()
var noise_position: float
var initial_gravity := self.gravity

@onready var collision_shape: CollisionShape2D = %CollisionShape2D


func _ready() -> void:
	self.noise.seed = randi()
	self.noise_position = self.initial_noise_position


func _physics_process(delta: float) -> void:
	self.noise_position += delta * self.change_rate
	self.wind = Vector2(
		self.noise.get_noise_1d(self.noise_position) * self.noise_multiplier,
		self.noise.get_noise_1d(-self.noise_position) * self.noise_multiplier
	).limit_length()

	if self.wind.x != 0:
		if ship1.linear_velocity.y > 16:
			ship1.correctNYMovement(self.wind.x)
		if ship1.linear_velocity.y < -16:
			ship1.correctYMovement(self.wind.x)

	if self.wind.y != 0:
		if ship1.linear_velocity.x < -16 || ship1.linear_velocity.x > 16:
			ship1.correctNXMovement(self.wind.y)
