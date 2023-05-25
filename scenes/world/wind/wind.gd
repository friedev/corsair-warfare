class_name Wind extends Node

@export var change_rate: float
@export var noise_multiplier: float
@export var initial_noise_position: float

var wind: Vector2
var noise := FastNoiseLite.new()
var noise_position: float


func _ready() -> void:
	self.noise.seed = randi()
	self.noise_position = self.initial_noise_position


func _physics_process(delta: float) -> void:
	self.noise_position += delta * self.change_rate
	var x := self.noise.get_noise_1d(self.noise_position)
	var y := self.noise.get_noise_1d(-self.noise_position)
	x = sign(x) * sqrt(abs(x))
	y = sign(y) * sqrt(abs(y))
	self.wind = Vector2(x, y).limit_length()
