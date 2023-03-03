extends RigidBody2D
class_name Ship

const bulletPath = preload('res://scenes/Bullets.tscn')

enum Player {
	P1 = 1,
	P2 = 2,
}


@export var player: Player
@export var texture: Texture2D
@export var speed: float
@export var rotation_speed: float

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

var can_fire := true

@onready var sprite: Sprite2D = %Sprite2D
@onready var control_parent: Node2D = %ControlParent
@onready var health_bar: ProgressBar = %HealthBar
@onready var cannon_ray_cast = %CannonRayCast2D
@onready var cooldown_timer = %CooldownTimer


func _ready() -> void:
	self.sprite.texture = texture
	self.health = self.max_health


func _process(delta: float) -> void:
	self.control_parent.global_rotation = 0


func _physics_process(delta: float) -> void:
	var action_prefix: String
	if self.player == Player.P1:
		action_prefix = "p1"
	elif self.player == Player.P2:
		action_prefix = "p2"

	if Input.is_action_pressed("%s_left" % action_prefix):
		self.apply_torque(-rotation_speed)
	if Input.is_action_pressed("%s_right" % action_prefix):
		self.apply_torque(rotation_speed)
	if Input.is_action_pressed("%s_fire_right" % action_prefix) and self.can_fire:
		shoot(90)
	if Input.is_action_pressed("%s_fire_left" % action_prefix) and self.can_fire:
		shoot(270)
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


func shoot(angle: float):
	var direction = Vector2.RIGHT.rotated(global_rotation + deg_to_rad(angle))
	var bullet = bulletPath.instantiate()

	bullet.direction = direction
	bullet.global_position = self.cannon_ray_cast.global_position
	bullet.add_collision_exception_with(self)
	get_parent().add_child(bullet)

	self.can_fire = false
	self.cooldown_timer.start()


func destroy() -> void:
	print("Player %d died" % self.player)
	self.queue_free()


func _on_cooldown_timer_timeout() -> void:
	self.can_fire = true
