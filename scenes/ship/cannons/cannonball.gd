class_name Cannonball extends RigidBody2D

@export var speed: float
@export var damage: float
@export var distance: float
@export var distance_range: float
@export var splash_scene: PackedScene
@export var impact_scene: PackedScene

var start_position: Vector2
var max_distance: float
var player: int


func _ready() -> void:
	self.linear_velocity = Vector2.RIGHT.rotated(self.rotation) * self.speed
	self.start_position = self.global_position
	self.max_distance = self.distance + self.distance_range * (randf() - 0.5)


func _physics_process(delta: float) -> void:
	if self.global_position.distance_to(start_position) > self.max_distance:
		self.splash()
		self.queue_free()


func _on_body_entered(body: Node) -> void:
	if body is Ship:
		var ship := body as Ship
		ship.take_damage(self.damage, self.player)
	self.impact()
	self.queue_free()


func splash() -> void:
	var splash_node := self.splash_scene.instantiate()
	splash_node.position = self.position
	self.add_sibling(splash_node)


func impact() -> void:
	var impact_node := self.impact_scene.instantiate()
	impact_node.position = self.position
	impact_node.global_rotation = self.global_rotation + PI
	self.add_sibling(impact_node)
