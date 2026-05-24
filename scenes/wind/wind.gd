class_name Wind
extends Node

@export var change_rate: float
@export var noise_multiplier: float
@export var initial_noise_position: float

var wind: Vector2
var noise := FastNoiseLite.new()
var noise_position: float


func _ready() -> void:
	noise.seed = randi()
	noise_position = initial_noise_position


func _physics_process(delta: float) -> void:
	noise_position += delta * change_rate
	var x := noise.get_noise_1d(noise_position)
	var y := noise.get_noise_1d(-noise_position)
	x = sign(x) * sqrt(abs(x))
	y = sign(y) * sqrt(abs(y))
	wind = Vector2(x, y).limit_length()
