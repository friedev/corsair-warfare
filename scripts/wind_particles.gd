extends GPUParticles2D


@export var added_velocity_multiplier: float
@export var wind: Wind

var velocity_min_base: float
var velocity_max_base: float


func _ready() -> void:
	# TODO update when screen resizes
	var particle_material := self.process_material as ParticleProcessMaterial
	self.velocity_min_base = particle_material.initial_velocity_min
	self.velocity_max_base = particle_material.initial_velocity_max
	var viewport_size := self.get_viewport_rect().size
	particle_material.emission_box_extents = Vector3(viewport_size.x, viewport_size.y, 0)


func _process(delta: float) -> void:
	var particle_material := self.process_material as ParticleProcessMaterial
	particle_material.direction = Vector3(self.wind.wind.x, self.wind.wind.y, 0)
	particle_material.angle_min = rad_to_deg(-self.wind.wind.angle())
	particle_material.angle_max = rad_to_deg(-self.wind.wind.angle())
	var added_velocity := self.added_velocity_multiplier * self.wind.wind.length()
	particle_material.initial_velocity_min = self.velocity_min_base + added_velocity
	particle_material.initial_velocity_max = self.velocity_max_base + added_velocity
