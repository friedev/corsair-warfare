class_name Cannonball
extends RigidBody2D

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
	linear_velocity = Vector2.RIGHT.rotated(rotation) * speed
	start_position = global_position
	max_distance = distance + distance_range * (randf() - 0.5)


func _physics_process(delta: float) -> void:
	if global_position.distance_to(start_position) > max_distance:
		splash()
		queue_free()


func _on_body_entered(body: Node) -> void:
	if body is Ship:
		var ship := body as Ship
		ship.take_damage(damage, player)
	impact()
	queue_free()


func splash() -> void:
	var splash_node := splash_scene.instantiate()
	splash_node.position = position
	add_sibling(splash_node)


func impact() -> void:
	var impact_node := impact_scene.instantiate()
	impact_node.position = position
	impact_node.global_rotation = global_rotation + PI
	add_sibling(impact_node)
