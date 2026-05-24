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
	reload_bar.value = (
		reload_bar.max_value
		* (1 - reload_timer.time_left / reload_timer.wait_time)
	)

func can_fire() -> bool:
	return reload_timer.is_stopped()


func spawn_cannonball(ball_position: Vector2, player: int) -> void:
	var cannonball = cannonball_scene.instantiate()
	cannonball.global_position = ball_position
	cannonball.global_rotation = global_rotation
	cannonball.player = player
	cannonball.add_collision_exception_with(get_parent())
	SignalBus.node_spawned.emit(cannonball)


func fire(cannon_count: int, player: int) -> void:
	var p := spawn_point_1.global_position
	var q := spawn_point_2.global_position
	for i in range(cannon_count):
		var offset_ratio := float(i) / float(cannon_count)
		var perpendicular_offset := max_cannonball_offset * randf()
		var ball_position := p + (q - p) * offset_ratio
		ball_position -= Vector2(perpendicular_offset, 0).rotated(rotation)
		spawn_cannonball(ball_position, player)
	fire_sound.pitch_scale = 1 + (randf() - 0.5) * 0.4
	fire_sound.play()
	fire_particles.restart()
	reload_timer.start()


func _on_reload_timer_timeout() -> void:
	reload_sound.pitch_scale = 1 + (randf() - 0.5) * 0.125
	reload_sound.play()
