extends GPUParticles2D

@export var added_velocity_multiplier: float
@export var wind: Wind

var velocity_min_base: float
var velocity_max_base: float


func update_emission_box() -> void:
	var viewport_size := get_viewport_rect().size
	var particle_material := process_material as ParticleProcessMaterial
	particle_material.emission_box_extents = Vector3(viewport_size.x, viewport_size.y, 0)


func _ready() -> void:
	var particle_material := process_material as ParticleProcessMaterial
	velocity_min_base = particle_material.initial_velocity_min
	velocity_max_base = particle_material.initial_velocity_max
	update_emission_box()

	get_tree().get_root().size_changed.connect(_on_window_size_changed)


func _process(delta: float) -> void:
	var particle_material := process_material as ParticleProcessMaterial
	particle_material.direction = Vector3(wind.wind.x, wind.wind.y, 0)
	particle_material.angle_min = rad_to_deg(-wind.wind.angle())
	particle_material.angle_max = rad_to_deg(-wind.wind.angle())
	var added_velocity := added_velocity_multiplier * wind.wind.length()
	particle_material.initial_velocity_min = velocity_min_base + added_velocity
	particle_material.initial_velocity_max = velocity_max_base + added_velocity


func _on_window_size_changed() -> void:
	update_emission_box()

