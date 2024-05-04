class_name Ship extends RigidBody2D

signal cannon_fired
signal damage_taken(damage: float)
signal destroyed(ship: Ship, destoyer: int)

const level_values := {
	"Hull": [1.0, 1.5, 2.0, 2.5],
	"Sails": [1.0, (4.0 / 3.0), (5.0 / 3.0), 2.0],
	"Cannons": [3, 4, 5, 6],
}

@export var player: int
@export var details: PlayerDetails

@export var wind: Wind

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
		health = clampf(value, 0, self.max_health)
		self.health_bar.value = self.health / self.max_health * self.health_bar.max_value
		if self.health > self.max_health * (2.0 / 3.0):
			self.medium_health_particles.emitting = false
			self.low_health_particles.emitting = false
		elif self.health > self.max_health * (1.0 / 3.0):
			self.medium_health_particles.emitting = true
			self.low_health_particles.emitting = false
		else:
			self.medium_health_particles.emitting = false
			self.low_health_particles.emitting = true

var nickname: String:
	set(value):
		nickname = value
		nickname_label.text = self.nickname

@export var sprite: ShipSprite
@export var control_parent: Node2D
@export var health_bar: ProgressBar
@export var left_cannons: Cannons
@export var right_cannons: Cannons
@export var collision_polygon: CollisionPolygon2D
@export var damage_sound: AudioStreamPlayer2D
@export var wake_particles: GPUParticles2D
@export var medium_health_particles: GPUParticles2D
@export var low_health_particles: GPUParticles2D
@export var damage_timer: Timer
@export var nickname_label: Label


func _ready() -> void:
	self.nickname = self.details.nickname
	self.sprite.apply_style(self.details.style)
	self.sprite.apply_levels(self.details.levels)

	# Apply levels
	self.max_health = self.level_values["Hull"][self.details.levels["Hull"]]
	self.health = self.max_health
	self.cannon_count = self.level_values["Cannons"][self.details.levels["Cannons"]]
	self.speed *= self.level_values["Sails"][self.details.levels["Sails"]]

	# Duplicate material so that changes by one ship don't affect the others
	var particle_material := self.wake_particles.process_material as ParticleProcessMaterial
	self.wake_particles.process_material = particle_material.duplicate()


func _process(delta: float) -> void:
	self.control_parent.global_rotation = 0

	var particle_material := self.wake_particles.process_material as ParticleProcessMaterial
	particle_material.angle_min = -self.rotation_degrees
	particle_material.angle_max = -self.rotation_degrees

	# Highlight my nickname if I'm winning
	var winner := Globals.get_winner()
	if winner != null and winner.player == self.details.player:
		self.nickname_label.modulate = Color(1, 0.75, 0)
	else:
		self.nickname_label.modulate = Color.WHITE


func handle_input() -> void:
	# TODO DRY
	if self.details.player == Globals.KEYBOARD_1_PLAYER:
		if Input.is_key_pressed(KEY_A):
			self.apply_torque(-self.rotation_speed)
		if Input.is_key_pressed(KEY_D):
			self.apply_torque(self.rotation_speed)
		if Input.is_key_pressed(KEY_Q):
			self.fire(self.left_cannons)
		if Input.is_key_pressed(KEY_E):
			self.fire(self.right_cannons)
	elif self.details.player == Globals.KEYBOARD_2_PLAYER:
		if Input.is_key_pressed(KEY_J):
			self.apply_torque(-self.rotation_speed)
		if Input.is_key_pressed(KEY_L):
			self.apply_torque(self.rotation_speed)
		if Input.is_key_pressed(KEY_U):
			self.fire(self.left_cannons)
		if Input.is_key_pressed(KEY_O):
			self.fire(self.right_cannons)
	else:
		var joy_axis := Input.get_joy_axis(self.details.player, JOY_AXIS_LEFT_X)
		self.apply_torque(self.rotation_speed * joy_axis)
		if Input.get_joy_axis(self.details.player, JOY_AXIS_TRIGGER_LEFT) > 0.5:
			self.fire(self.left_cannons)
		if Input.get_joy_axis(self.details.player, JOY_AXIS_TRIGGER_RIGHT) > 0.5:
			self.fire(self.right_cannons)


func _physics_process(delta: float) -> void:
	self.handle_input()
	self.apply_wind_force()
	self.apply_collision_damage(delta)


func is_vibrate_enabled() -> bool:
	return Globals.options.get("vibrate", true)


func fire(cannons: Cannons) -> void:
	if cannons.can_fire():
		cannons.fire(self.cannon_count)
		if Globals.is_joy(self.details.player) and self.is_vibrate_enabled():
			Input.start_joy_vibration(self.details.player, 0.5, 0.0, 0.25)
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
		var damager := Globals.NO_PLAYER
		if body is Ship:
			var other := body as Ship
			damager = other.details.player
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
		self.take_damage(damage_to_self, damager)


func take_damage(damage: float, damager := Globals.NO_PLAYER) -> void:
	if Globals.is_joy(self.details.player) and self.is_vibrate_enabled():
		Input.start_joy_vibration(self.details.player, 0.5, 0.25, 0.25)
	self.damage_taken.emit(damage)
	if self.damage_timer.is_stopped() and not self.damage_sound.is_playing():
		self.damage_sound.play()
	self.damage_timer.start()
	var previous_health := self.health
	self.health -= damage
	if previous_health > 0.0 and self.health <= 0:
		self.destroy(damager)


func destroy(destroyer := Globals.NO_PLAYER) -> void:
	self.destroyed.emit(self, destroyer)
	self.queue_free()
