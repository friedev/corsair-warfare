extends GPUParticles2D


func _ready() -> void:
	self.restart()


func _on_free_timer_timeout() -> void:
	self.queue_free()
