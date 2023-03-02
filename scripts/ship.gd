extends RigidBody2D

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


func _input(event: InputEvent) -> void:
	pass


func _process(delta: float) -> void:
	pass
	



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
	
	

