extends Camera2D

@export var ship1: Node2D
@export var ship2: Node2D


func _process(delta: float) -> void:
	var x_val := (ship1.position.x + ship2.position.x) * 0.5
	var y_val := (ship1.position.y + ship2.position.y) * 0.5
	self.set_offset(Vector2(x_val, y_val))

	# Distance isn't the best way to do this. Since the viewport is a rectangle,
	# I need to find a way to implement zoom only when they're x distance away
	# from the edge of the screen.
	# I should handle the x and y distances differently in order to accommodate
	# for the longer size.
	# TODO: Figure out a way to use x & y coordinates instead of distance.

	# The current problem is that I'm not scaling the numbers up to the distance
	# they are away.
	# If they're outside of the bounds, then x and y won't apply, even when
	# they should.
	# Find a way to scale the minimum values up.

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