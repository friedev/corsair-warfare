extends RigidBody2D
class_name Ship

const bulletPath = preload('res://scenes/Bullets.tscn')

enum Player {
	P1 = 1,
	P2 = 2,
}


@export var player: Player
@export var speed: float
@export var rotation_speed: float
@export var _cooldown_timer: Node

var _can_fire := true
@export var ram_dps_min: float
@export var ram_dps_max: float
@export var obstacle_dps: float

@export var max_health: float
var health: float:
	set(value):
		health = clampf(value, 0, self.max_health)
		if self.health == 0:
			self.destroy()
		self.health_bar.value = self.health / self.max_health * self.health_bar.max_value

@onready var control_parent: Node2D = %ControlParent
@onready var health_bar: ProgressBar = %HealthBar


func _ready() -> void:
	self.health = self.max_health


func _process(delta: float) -> void:
	self.control_parent.global_rotation = 0


func _physics_process(delta: float) -> void:
	var _ray_cast = $RayCast2D
	var _cooldown_timer = $Timer
	var sprite
	if self.player == Player.P1:
		if Input.is_action_pressed("p1_left"):
			self.apply_torque(-rotation_speed)
		if Input.is_action_pressed("p1_right"):
			self.apply_torque(rotation_speed)
		if Input.is_action_just_pressed("p1_fire_right") and _can_fire:
			shoot(90)
			_can_fire = true
			_cooldown_timer.start()
		if Input.is_action_just_pressed("p1_fire_left") and _can_fire:
			shoot(270)
			_can_fire = true
			_cooldown_timer.start()
	elif self.player == Player.P2:
		if Input.is_action_pressed("p2_left"):
			self.apply_torque(-rotation_speed)
		if Input.is_action_pressed("p2_right"):
			self.apply_torque(rotation_speed)
		if Input.is_action_just_pressed("p2_fire_right") and _can_fire:
			shoot(90)
			_can_fire = true
			_cooldown_timer.start()
		if Input.is_action_just_pressed("p2_fire_left") and _can_fire:
			shoot(270)
			_can_fire = true
			_cooldown_timer.start()
	self.apply_force(Vector2.RIGHT.rotated(self.rotation) * speed)
	self.apply_collision_damage(delta)


func apply_collision_damage(delta: float):
	for body in self.get_colliding_bodies():
		# Take damage from colliding ships or other obstacles over time
		var damage_to_self: float
		if body is Ship:
			var other := body as Ship
			# Always take some damage while ramming
			damage_to_self = other.ram_dps_min
			# Take more damage if the other ship is hitting me straight on
			var angle_other_to_self := other.get_angle_to(self.position)
			if -PI / 2 < angle_other_to_self and angle_other_to_self < PI / 2:
				damage_to_self += (
					(1.0 - absf(angle_other_to_self) / (PI / 2))
					* (other.ram_dps_max - other.ram_dps_min)
				)
		else:
			damage_to_self = self.obstacle_dps
		damage_to_self *= delta
#		print("I am P%d" % self.player)
#		print("other angle: %f" % angle_other_to_self)
#		print("damage multiplier: %f" % (1.0 - absf(angle_other_to_self) / (PI / 2)))
#		print("damage to self: %f" % damage_to_self)
		self.health -= damage_to_self


func shoot(angle):
	var _ray_cast = $RayCast2D
	var _cooldown_timer = $Timer
	var direction = Vector2.RIGHT.rotated(global_rotation + deg_to_rad(angle))
	var bullet = bulletPath.instantiate()

	bullet.direction = direction
	bullet.global_position = _ray_cast.global_position
	bullet.add_collision_exception_with(self)
	get_parent().add_child(bullet)


func _on_Timer_timeout():
	_can_fire = true



func destroy() -> void:
	print("Player %d died" % self.player)
	self.queue_free()
