extends Area2D
class_name WindArea

signal wind_changed(wind: Vector2)

@export var ship1: Ship
@export var ship2: Ship

var wind_directions: Array[Vector2] = [
	Vector2(1, 0),
	Vector2(0, 0.5),
	Vector2(0.5, 0.5),
	Vector2(0, -1),
	Vector2(0.25, 0),
]

var wind: Vector2

@onready var collision_shape: CollisionShape2D = %CollisionShape2D
@onready var wind_change_timer: Timer = %WindChangeTimer


func _ready():
	self.change_wind_direction()


func _physics_process(delta: float) -> void:
	if self.wind.x != 0:
		if ship1.linear_velocity.y > 16:
			ship1.correctNYMovement(self.wind.x)
		if ship1.linear_velocity.y < -16:
			ship1.correctYMovement(self.wind.x)

	if self.wind.y != 0:
		if ship1.linear_velocity.x < -16 || ship1.linear_velocity.x > 16:
			ship1.correctNXMovement(self.wind.y)


func change_wind_direction():
	var index = randi() % wind_directions.size()
	self.wind =  wind_directions[index]
#	var current_wind = Vector2(2, 0)
	self.set_gravity_direction(self.wind)
	self.wind_changed.emit(self.wind)
	print("gravity direction:", self.wind)


func _on_timer_timeout():
	self.change_wind_direction()
