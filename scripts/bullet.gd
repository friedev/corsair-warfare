# TODO drag
# TODO splash into the ocean after a certain range (simulate height? or just based on speed)

extends RigidBody2D

@export var speed: float

func _ready() -> void:
	self.linear_velocity = Vector2.RIGHT.rotated(self.rotation) * self.speed


func _on_VisiblityNotifier2D_screen_exited() -> void:
	self.queue_free()


func _on_body_entered(body: Node) -> void:
	print("body entered")
	if body is Ship:
		# TODO do damage
		print("hit ship")
		pass
	self.queue_free()
