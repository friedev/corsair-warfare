extends Area2D
 

var wind_directions = [
	Vector2(1, 0),
	Vector2(0, 0.5),
	Vector2(0.5, 0.5),
	Vector2(0, -1),
	Vector2(0.25, 0),
]

var xWind = null
var yWind = null
@onready var ship1 = get_node("/root/Main/Ship1")
@onready var ship2 = get_node("/root/Main/Ship2")
#test
# Called when the node enters the scene tree for the first time.
func _ready():
	var timer = $Timer
	timer.wait_time = 10
	timer.start()
	_on_timer_timeout()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	if xWind != 0:
		if ship1.linear_velocity.y > 16:
			ship1.correctNYMovement(xWind)
		if ship1.linear_velocity.y < -16:
			ship1.correctYMovement(xWind)
	
	if yWind != 0:
		if ship1.linear_velocity.x < -16 || ship1.linear_velocity.x > 16:
			ship1.correctNXMovement(yWind)

func change_wind_direction():
	var index = randi() % wind_directions.size()
	var current_wind = wind_directions[index]
#	var current_wind = Vector2(2, 0)
	self.set_gravity_direction(current_wind)
	print("gravity direction:", current_wind)
	xWind = current_wind.x
	yWind = current_wind.y


func _on_timer_timeout():
	change_wind_direction()
	
