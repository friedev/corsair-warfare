extends RigidBody2D
class_name Ship


enum Player {
	P1 = 1,
	P2 = 2,
}


@export var player: Player
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

@onready var control_parent: Node2D = %ControlParent
@onready var health_bar: ProgressBar = %HealthBar


func _ready() -> void:
	self.health = self.max_health


func _process(delta: float) -> void:
	self.control_parent.global_rotation = 0


func _physics_process(delta: float) -> void:
	if self.player == Player.P1:
		if Input.is_action_pressed("p1_left"):
			self.apply_torque(-rotation_speed)
		if Input.is_action_pressed("p1_right"):
			self.apply_torque(rotation_speed)
	elif self.player == Player.P2:
		if Input.is_action_pressed("p2_left"):
			self.apply_torque(-rotation_speed)
		if Input.is_action_pressed("p2_right"):
			self.apply_torque(rotation_speed)
	self.apply_force(Vector2.RIGHT.rotated(self.rotation) * speed)
	self.apply_collision_damage(delta)
#	print("Linerar Velocity: ", self.linear_velocity.x)
	


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


func destroy() -> void:
	print("Player %d died" % self.player)
	self.queue_free()

func correctYMovement(current_wind):
	var impulse = Vector2.ZERO
	impulse.x = self.mass * 0.43
	impulse *= -current_wind
	self.apply_central_impulse(impulse)

func correctNYMovement(current_wind):
	var impulse = Vector2.ZERO
	impulse.x = self.mass * .043
	impulse *= current_wind
	self.apply_central_impulse(impulse)
	
func correctXMovement(current_wind):
	var impulse = Vector2.ZERO
	impulse.y = self.mass * .5
	impulse *= -current_wind
	self.apply_central_impulse(impulse)
	
func correctNXMovement(current_wind):
	var impulse = Vector2.ZERO
	impulse.y = self.mass * .5
	impulse *= -current_wind
	self.apply_central_impulse(impulse)

