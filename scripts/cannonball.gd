extends RigidBody2D
class_name Cannonball

@export var speed: float
@export var damage: float
@export var distance: float
@export var distance_range: float
@export var cannon_splash: PackedScene

var start_position: Vector2
var max_distance: float


func _ready() -> void:
	self.linear_velocity = Vector2.RIGHT.rotated(self.rotation) * self.speed
	self.start_position = self.global_position
	self.max_distance = self.distance + self.distance_range * (randf() - 0.5)


func _physics_process(delta: float) -> void:
	if self.global_position.distance_to(start_position) > self.max_distance:
		self.splash()
		self.queue_free()


func splash() -> void:
	var splash_node := self.cannon_splash.instantiate()
	splash_node.position = self.position
	self.add_sibling(splash_node)


func _on_body_entered(body: Node) -> void:
	if body is Ship:
		var ship = body as Ship
		ship.health -= self.damage
	self.queue_free()
