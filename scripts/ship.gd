extends RigidBody2D
class_name Ship

signal cannon_fired
signal damage_taken(damage: float)
signal destroyed(ship: Ship)

const max_cannonball_offset := 10.0

enum Player {
	P1 = 1,
	P2 = 2,
}

@export var player: Player

@export var wind: Wind

@export var texture: Texture2D

@export var speed: float
@export var min_speed: float
@export var rotation_speed: float

@export var ram_dps_min: float
@export var ram_dps_max: float
@export var obstacle_dps: float

@export var max_health: float

@export var cannon_count: int
@export var cannonball_scene: PackedScene


var health: float:
	set(value):
		if value < self.health:
			Input.start_joy_vibration(getDevice(), 0.1, clamp((self.health - value) * 10, 0.1, 1), 0.15)
			self.damage_taken.emit(self.health - value)
			if self.damage_timer.is_stopped() and not self.damage_sound.is_playing():
				self.damage_sound.play()
			self.damage_timer.start()

		health = clampf(value, 0, self.max_health)
		if self.health == 0:
			self.destroy()

		self.health_bar.value = self.health / self.max_health * self.health_bar.max_value
		# Update sprite based on health
		if self.health > self.max_health * (2.0 / 3.0):
			self.medium_health_particles.emitting = false
			self.low_health_particles.emitting = false
		elif self.health > self.max_health * (1.0 / 3.0):
			self.medium_health_particles.emitting = true
			self.low_health_particles.emitting = false
		else:
			self.medium_health_particles.emitting = false
			self.low_health_particles.emitting = true

var can_fire_l := true
var can_fire_r := true

var enabled := true:
	set(value):
		enabled = value
		self.visible = self.enabled
		self.set_process(self.enabled)
		self.set_physics_process(self.enabled)
		self.set_process_input(self.enabled)
		self.collision_polygon.set_deferred(&"disabled", not self.enabled)

@onready var sprite: Sprite2D = %Sprite2D
@onready var control_parent: Node2D = %ControlParent
@onready var health_bar: ProgressBar = %HealthBar
@onready var cannon_bar_l: ProgressBar = %CannonBarL
@onready var cannon_bar_r: ProgressBar = %CannonBarR

@onready var cooldown_timer_l: Timer = %CooldownTimerL
@onready var cooldown_timer_r: Timer = %CooldownTimerR
@onready var cannon_particles_l: GPUParticles2D = %CannonParticlesL
@onready var cannon_particles_r: GPUParticles2D = %CannonParticlesR
@onready var cannon_sound_l: AudioStreamPlayer2D = %CannonSoundL
@onready var cannon_sound_r: AudioStreamPlayer2D = %CannonSoundR
@onready var cannon_reload_sound: AudioStreamPlayer2D = %CannonReload
@onready var cannon_point_l1: Node2D = %CannonPointL1
@onready var cannon_point_l2: Node2D = %CannonPointL2
@onready var cannon_point_r1: Node2D = %CannonPointR1
@onready var cannon_point_r2: Node2D = %CannonPointR2

@onready var collision_polygon: CollisionPolygon2D = %CollisionPolygon2D
@onready var damage_sound: AudioStreamPlayer2D = %DamageSound
@onready var wake_particles: GPUParticles2D = %WakeParticles
@onready var medium_health_particles: GPUParticles2D = %MediumHealthParticles
@onready var low_health_particles: GPUParticles2D = %LowHealthParticles
@onready var damage_timer: Timer = %DamageTimer


func _ready() -> void:
	self.sprite.texture = self.texture
	self.health = self.max_health
	# Duplicate material so that changes by one ship don't affect the other
	var particle_material := self.wake_particles.process_material as ParticleProcessMaterial
	self.wake_particles.process_material = particle_material.duplicate()


func _process(delta: float) -> void:
	self.control_parent.global_rotation = 0
	var particle_material := self.wake_particles.process_material as ParticleProcessMaterial
	particle_material.angle_min = -self.rotation_degrees
	particle_material.angle_max = -self.rotation_degrees


func _physics_process(delta: float) -> void:
	self.cannon_bar_l.value = (
		self.cannon_bar_l.max_value
		* (1 - self.cooldown_timer_l.time_left / self.cooldown_timer_l.wait_time)
	)
	self.cannon_bar_r.value = (
		self.cannon_bar_r.max_value
		* (1 - self.cooldown_timer_r.time_left / self.cooldown_timer_r.wait_time)
	)

	var action_prefix: String
	if self.player == Player.P1:
		action_prefix = "p1"
	elif self.player == Player.P2:
		action_prefix = "p2"

	if Input.is_action_pressed("%s_left" % action_prefix):
		self.apply_torque(-self.rotation_speed)
	if Input.is_action_pressed("%s_right" % action_prefix):
		self.apply_torque(self.rotation_speed)
	if Input.is_action_pressed("%s_fire_right" % action_prefix) and self.can_fire_r:
		self.fire_cannons_right()
	if Input.is_action_pressed("%s_fire_left" % action_prefix) and self.can_fire_l:
		self.fire_cannons_left()
	self.apply_wind_force()
	self.apply_collision_damage(delta)


func apply_wind_force() -> void:
	var difference := self.rotation - self.wind.wind.angle()
	# https://stackoverflow.com/a/2007355
	var actual_difference: float = min(abs(difference), abs(difference + TAU), abs(difference - TAU))
	var alignment := 1.0 - actual_difference / PI
	var magnitude := self.speed * self.wind.wind.length() * sqrt(alignment)
	magnitude = max(magnitude, self.min_speed)
	var force := Vector2(1, 0).rotated(self.rotation) * magnitude
	self.apply_force(force)


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
		self.health -= damage_to_self


func spawn_cannonball(ball_position: Vector2, ball_rotation: float):
	var cannonball = self.cannonball_scene.instantiate()
	cannonball.global_position = ball_position
	cannonball.rotation = ball_rotation
	cannonball.add_collision_exception_with(self)
	self.get_parent().add_child(cannonball)


func fire_cannons(point1: Vector2, point2: Vector2, ball_rotation: float):
	for i in range(self.cannon_count):
		var offset_ratio := float(i) / float(self.cannon_count)
		var perpendicular_offset := self.max_cannonball_offset * randf()
		var ball_position := point1 + (point2 - point1) * offset_ratio
		ball_position -= Vector2(perpendicular_offset, 0).rotated(ball_rotation)
		self.spawn_cannonball(ball_position, ball_rotation)
	self.cannon_fired.emit()
	Input.start_joy_vibration(self.getDevice(), 0.5, 0.0, 0.25)


func fire_cannons_right():
	self.fire_cannons(
		self.cannon_point_r1.global_position,
		self.cannon_point_r2.global_position,
		PI / 2 + self.rotation
	)
	self.can_fire_r = false
	self.cannon_sound_r.pitch_scale = 1 + (randf() - 0.5) * 0.125
	self.cannon_sound_r.play()
	self.cannon_particles_r.restart()
	self.cooldown_timer_r.start()



func fire_cannons_left():
	self.fire_cannons(
		self.cannon_point_l1.global_position,
		self.cannon_point_l2.global_position,
		-PI / 2 + self.rotation
	)
	self.can_fire_l = false
	self.cannon_sound_l.pitch_scale = 1 + (randf() - 0.1) * 0.4
	self.cannon_sound_l.play()
	self.cannon_particles_l.restart()
	self.cooldown_timer_l.start()


func destroy() -> void:
	self.enabled = false
	self.destroyed.emit(self)


func _on_cooldown_timer_l_timeout() -> void:
	self.can_fire_l = true
	self.cannon_reload_sound.pitch_scale = 1 + (randf() - 0.5) * 0.4
	self.cannon_reload_sound.play()


func _on_cooldown_timer_r_timeout() -> void:
	self.can_fire_r = true
	self.cannon_reload_sound.pitch_scale = 1 + (randf() - 0.5) * 0.4
	self.cannon_reload_sound.play()


func getDevice() -> int:
	var device: int
	if self.player == Player.P1:
		device = 1
	elif self.player == Player.P2:
		device = 0
	return device
