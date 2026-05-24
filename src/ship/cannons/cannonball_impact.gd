extends GPUParticles2D

func _ready() -> void:
	restart()


func _on_free_timer_timeout() -> void:
	queue_free()
