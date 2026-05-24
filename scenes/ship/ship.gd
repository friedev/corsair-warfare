class_name Ship extends RigidBody2D

signal cannon_fired
signal damage_taken(damage: float)
signal destroyed(ship: Ship, destoyer: int)

const level_values := {
	"Hull": [1.0, 1.5, 2.0, 2.5],
	"Sails": [1.0, (4.0 / 3.0), (5.0 / 3.0), 2.0],
	"Cannons": [3, 4, 5, 6],
}

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
		health = clampf(value, 0, max_health)
		health_bar.value = health / max_health * health_bar.max_value
		if health > max_health * (2.0 / 3.0):
			medium_health_particles.emitting = false
			low_health_particles.emitting = false
		elif health > max_health * (1.0 / 3.0):
			medium_health_particles.emitting = true
			low_health_particles.emitting = false
		else:
			medium_health_particles.emitting = false
			low_health_particles.emitting = true

var nickname: String:
	set(value):
		nickname = value
		nickname_label.text = nickname

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
	nickname = details.nickname
	sprite.apply_style(details.style)
	sprite.apply_levels(details.levels)

	# Apply levels
	max_health = level_values["Hull"][details.levels["Hull"]]
	health = max_health
	cannon_count = level_values["Cannons"][details.levels["Cannons"]]
	speed *= level_values["Sails"][details.levels["Sails"]]

	# Duplicate material so that changes by one ship don't affect the others
	var particle_material := wake_particles.process_material as ParticleProcessMaterial
	wake_particles.process_material = particle_material.duplicate()


func _process(delta: float) -> void:
	control_parent.global_rotation = 0

	var particle_material := wake_particles.process_material as ParticleProcessMaterial
	particle_material.angle_min = -rotation_degrees
	particle_material.angle_max = -rotation_degrees

	# Highlight my nickname if I'm winning
	var winner := Globals.get_winner()
	if winner != null and winner.player == details.player:
		nickname_label.modulate = Color(1, 0.75, 0)
	else:
		nickname_label.modulate = Color.WHITE


func handle_input() -> void:
	# TODO DRY
	if details.player == Globals.KEYBOARD_1_PLAYER:
		if Input.is_key_pressed(KEY_A):
			apply_torque(-rotation_speed)
		if Input.is_key_pressed(KEY_D):
			apply_torque(rotation_speed)
		if Input.is_key_pressed(KEY_Q):
			fire(left_cannons)
		if Input.is_key_pressed(KEY_E):
			fire(right_cannons)
	elif details.player == Globals.KEYBOARD_2_PLAYER:
		if Input.is_key_pressed(KEY_J):
			apply_torque(-rotation_speed)
		if Input.is_key_pressed(KEY_L):
			apply_torque(rotation_speed)
		if Input.is_key_pressed(KEY_U):
			fire(left_cannons)
		if Input.is_key_pressed(KEY_O):
			fire(right_cannons)
	else:
		var joy_axis := Input.get_joy_axis(details.player, JOY_AXIS_LEFT_X)
		apply_torque(rotation_speed * joy_axis)
		if Input.get_joy_axis(details.player, JOY_AXIS_TRIGGER_LEFT) > 0.5:
			fire(left_cannons)
		if Input.get_joy_axis(details.player, JOY_AXIS_TRIGGER_RIGHT) > 0.5:
			fire(right_cannons)


func _physics_process(delta: float) -> void:
	handle_input()
	apply_wind_force()
	apply_collision_damage(delta)


func vibrate(weak_magnitude: float, strong_magnitude: float, duration: float) -> void:
	if Globals.is_joy(details.player):
		var vibrate_amount: float = Globals.options.get("vibrate_amount", 0.5)
		weak_magnitude = clamp(weak_magnitude * vibrate_amount, 0.0, 1.0)
		strong_magnitude = clamp(strong_magnitude * vibrate_amount, 0.0, 1.0)
		if vibrate_amount > 0.0:
			Input.start_joy_vibration(
				details.player,
				weak_magnitude,
				strong_magnitude,
				duration
			)


func fire(cannons: Cannons) -> void:
	if cannons.can_fire():
		cannons.fire(cannon_count, details.player)
		vibrate(1.0, 0.0, 0.25)
		cannon_fired.emit()


func apply_wind_force() -> void:
	var difference := rotation - wind.wind.angle()
	# https://stackoverflow.com/a/2007355
	var actual_difference: float = min(
		abs(difference),
		abs(difference + TAU),
		abs(difference - TAU)
	)
	var alignment := 1.0 - actual_difference / PI
	var magnitude := speed * wind.wind.length() * sqrt(alignment)
	magnitude = max(magnitude, min_speed)
	var force := Vector2(1, 0).rotated(rotation) * magnitude
	apply_force(force)


func apply_collision_damage(delta: float):
	for body in get_colliding_bodies():
		# Take damage from colliding ships or other obstacles over time
		var damage_to_self: float
		var damager := Globals.NO_PLAYER
		if body is Ship:
			var other := body as Ship
			damager = other.details.player
			# Always take some damage while ramming
			damage_to_self = other.ram_dps_min
			# Take more damage if the other ship is hitting me straight on
			var angle_other_to_self := other.get_angle_to(position)
			if -PI / 2 < angle_other_to_self and angle_other_to_self < PI / 2:
				damage_to_self += (
					(1.0 - absf(angle_other_to_self) / (PI / 2))
					* (other.ram_dps_max - other.ram_dps_min)
				)
		else:
			damage_to_self = obstacle_dps
		damage_to_self *= delta
		take_damage(damage_to_self, damager)


func take_damage(damage: float, damager := Globals.NO_PLAYER) -> void:
	vibrate(1.0, 0.5, 0.25)
	damage_taken.emit(damage)
	if damage_timer.is_stopped() and not damage_sound.is_playing():
		damage_sound.play()
	damage_timer.start()
	var previous_health := health
	health -= damage
	if previous_health > 0.0 and health <= 0:
		destroy(damager)


func destroy(destroyer := Globals.NO_PLAYER) -> void:
	destroyed.emit(self, destroyer)
	queue_free()
