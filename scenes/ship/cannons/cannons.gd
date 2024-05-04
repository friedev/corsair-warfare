class_name Cannons extends Node2D

const max_cannonball_offset := 10.0
const cannonball_scene := preload("res://scenes/ship/cannons/cannonball.tscn")

@export var spawn_point_1: Node2D
@export var spawn_point_2: Node2D
@export var reload_timer: Timer
@export var reload_bar: ProgressBar
@export var fire_particles: GPUParticles2D
@export var fire_sound: AudioStreamPlayer2D
@export var reload_sound: AudioStreamPlayer2D


func _process(delta: float) -> void:
	self.reload_bar.value = (
		self.reload_bar.max_value
		* (1 - self.reload_timer.time_left / self.reload_timer.wait_time)
	)

func can_fire() -> bool:
	return self.reload_timer.is_stopped()


func spawn_cannonball(ball_position: Vector2) -> void:
	var cannonball = self.cannonball_scene.instantiate()
	cannonball.global_position = ball_position
	cannonball.global_rotation = self.global_rotation
	# TODO find a better way to access the ship firing these cannons
	cannonball.player = self.get_parent().details.player
	cannonball.add_collision_exception_with(self.get_parent())
	# TODO find a better way to access the World node
	self.get_parent().get_parent().add_child(cannonball)


func fire(cannon_count: int) -> void:
	var p := self.spawn_point_1.global_position
	var q := self.spawn_point_2.global_position
	for i in range(cannon_count):
		var offset_ratio := float(i) / float(cannon_count)
		var perpendicular_offset := self.max_cannonball_offset * randf()
		var ball_position := p + (q - p) * offset_ratio
		ball_position -= Vector2(perpendicular_offset, 0).rotated(self.rotation)
		self.spawn_cannonball(ball_position)
	self.fire_sound.pitch_scale = 1 + (randf() - 0.5) * 0.4
	self.fire_sound.play()
	self.fire_particles.restart()
	self.reload_timer.start()


func _on_reload_timer_timeout() -> void:
	self.reload_sound.pitch_scale = 1 + (randf() - 0.5) * 0.125
	self.reload_sound.play()
