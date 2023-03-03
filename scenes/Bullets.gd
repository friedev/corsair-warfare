extends CharacterBody2D

var direction := Vector2.RIGHT

var speed := 300.0

func _ready():
	set_as_top_level(true)
	direction = direction.normalized()
	look_at(direction + global_position)
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta):
	var v = direction * speed * delta
	var c:= move_and_collide(v)
	if c and c.get_collider():
		# Do damage
		queue_free()

func _on_VisiblityNotifier2D_screen_exited():
	queue_free()
