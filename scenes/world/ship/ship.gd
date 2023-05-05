extends RigidBody2D
class_name Ship

signal cannon_fired
signal damage_taken(damage: float)
signal destroyed(ship: Ship)

@export var player: int

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


var health: float:
	set(value):
		if value < self.health:
			Input.start_joy_vibration(
				self.get_device(),
				0.1,
				clamp((self.health - value) * 10, 0.1, 1),
				0.15
			)
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
@onready var left_cannons: Cannons = %LeftCannons
@onready var right_cannons: Cannons = %RightCannons
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
	var action_prefix := "p%d" % self.player
	if Input.is_action_pressed("%s_left" % action_prefix):
		self.apply_torque(-self.rotation_speed)
	if Input.is_action_pressed("%s_right" % action_prefix):
		self.apply_torque(self.rotation_speed)
	if Input.is_action_pressed("%s_fire_right" % action_prefix):
		self.fire(self.right_cannons)
	if Input.is_action_pressed("%s_fire_left" % action_prefix):
		self.fire(self.left_cannons)
	self.apply_wind_force()
	self.apply_collision_damage(delta)


func fire(cannons: Cannons) -> void:
	if cannons.can_fire():
		cannons.fire(self.cannon_count)
		Input.start_joy_vibration(self.get_device(), 0.5, 0.0, 0.25)
		self.cannon_fired.emit()


func apply_wind_force() -> void:
	var difference := self.rotation - self.wind.wind.angle()
	# https://stackoverflow.com/a/2007355
	var actual_difference: float = min(
		abs(difference),
		abs(difference + TAU),
		abs(difference - TAU)
	)
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


func destroy() -> void:
	self.enabled = false
	self.destroyed.emit(self)


func get_device() -> int:
	return player - 1
