extends RigidBody2D


enum Player {
	P1 = 1,
	P2 = 2,
}


@export var player: Player
@export var speed: float
@export var rotation_speed: float

@export var max_health: int
@onready var health := self.max_health:
	set(value):
		health = clampi(value, 0, self.max_health)
		if self.health == 0:
			self.destroy()


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


func _on_body_entered(body: Node) -> void:
	self.health -= 1


func destroy() -> void:
	print("Player %d died" % self.player)
	self.queue_free()
