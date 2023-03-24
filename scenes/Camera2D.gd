extends Camera2D

@export var Ship1: Node2D
@export var Ship2: Node2D

# Called when the node enters the scene tree for the first time.
func _ready():
	pass


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	
	var x_val = (Ship1.position.x + Ship2.position.x) / 2
	var y_val = (Ship1.position.y + Ship2.position.y) / 2
	set_offset(Vector2(x_val, y_val))
	
	#Distance isn't the best way to do this. Since the viewport is a rectangle, I need to find a way
	#to implement zoom only when they're x distance away from the edge of the screen.
	#I should handle the x and y distances differently in order to accommodate for the longer size.
	#1600 x 800
	#TODO: Figure out a way to use x & y coordinates instead of distance.
	
	#The current problem is that I'm not scaling the numbers up to the distance they are away.
	#If they're outside of the bounds, then x and y won't apply, even when they should.
	#Find a way to scale the minimum values up.
	
	var dimensions = get_viewport_rect().size
	
	var screen_width = dimensions.x
	var screen_height = dimensions.y
	var screen_ratio = screen_width / screen_height
	
	var x_min = screen_width * 3/4
	var y_min = screen_height * 3/4
	var dist = Ship2.position - Ship1.position
	var x_dist = abs(dist.x)
	var y_dist = abs(dist.y)
	
	var zoom_val = get_zoom()
	
	if(x_dist > screen_ratio * y_dist and x_dist > x_min):
		zoom_val = Vector2(x_min / x_dist, x_min / x_dist)
	if(screen_ratio * y_dist > x_dist and y_dist > y_min):
		zoom_val = Vector2(y_min / y_dist, y_min / y_dist)
	
	set_zoom(get_zoom().lerp(zoom_val, 0.05))

	pass

func get_distance(n1, n2):
	return (n2.position - n1.position)
