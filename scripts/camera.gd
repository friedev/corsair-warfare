extends Camera2D

@export var ship1: Node2D
@export var ship2: Node2D

func _process(delta: float) -> void:
	var x_val := (ship1.position.x + ship2.position.x) * 0.5
	var y_val := (ship1.position.y + ship2.position.y) * 0.5
	self.set_offset(Vector2(x_val, y_val))

	var dimensions := self.get_viewport_rect().size

	var screen_width := dimensions.x
	var screen_height := dimensions.y
	var screen_ratio := screen_width / screen_height

	var x_min := screen_width * 0.75
	var y_min := screen_height * 0.75
	var dist := ship2.position - ship1.position
	var x_dist: float = abs(dist.x)
	var y_dist: float = abs(dist.y)

	var zoom_val := self.get_zoom()

	if x_dist > screen_ratio * y_dist and x_dist > x_min:
		zoom_val = Vector2(x_min / x_dist, x_min / x_dist)
	if screen_ratio * y_dist > x_dist and y_dist > y_min:
		zoom_val = Vector2(y_min / y_dist, y_min / y_dist)

	self.set_zoom(self.get_zoom().lerp(zoom_val, 0.05))
