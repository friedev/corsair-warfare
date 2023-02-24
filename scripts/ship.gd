extends RigidBody2D


enum Player {
	P1 = 1,
	P2 = 2,
}


@export var player: Player
@export var speed: float
@export var rotation_speed: float


func _physics_process(delta: float) -> void:
	if self.player == Player.P1:
		if Input.is_action_pressed("p1_left"):
			self.apply_torque(-rotation_speed)
		if Input.is_action_pressed("p1_right"):
			self.apply_torque(rotation_speed)
			print("DOING THE THING")
	elif self.player == Player.P2:
		if Input.is_action_pressed("p2_left"):
			self.apply_torque(-rotation_speed)
		if Input.is_action_pressed("p2_right"):
			self.apply_torque(rotation_speed)
	self.apply_force(Vector2.RIGHT.rotated(self.rotation) * speed)


func _input(event: InputEvent) -> void:
	pass


func _process(delta: float) -> void:
	pass
