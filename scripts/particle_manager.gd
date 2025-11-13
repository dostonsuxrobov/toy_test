extends Node3D
class_name ParticleManager

# Particle effect templates
var impact_particles: Dictionary = {}

func _ready() -> void:
	setup_particle_templates()

func setup_particle_templates() -> void:
	# Create particle templates for different materials
	impact_particles["wood"] = create_wood_impact()
	impact_particles["metal"] = create_metal_impact()
	impact_particles["default"] = create_default_impact()

func create_wood_impact() -> GPUParticles3D:
	var particles = GPUParticles3D.new()
	particles.amount = 20
	particles.lifetime = 0.5
	particles.one_shot = true
	particles.explosiveness = 1.0

	# Create particle material
	var material = ParticleProcessMaterial.new()
	material.emission_shape = ParticleProcessMaterial.EMISSION_SHAPE_SPHERE
	material.emission_sphere_radius = 0.1
	material.direction = Vector3(0, 1, 0)
	material.spread = 45.0
	material.initial_velocity_min = 1.0
	material.initial_velocity_max = 3.0
	material.gravity = Vector3(0, -9.8, 0)
	material.scale_min = 0.05
	material.scale_max = 0.1
	material.color = Color(0.6, 0.4, 0.2)  # Brown for wood

	particles.process_material = material

	# Create mesh
	var mesh = BoxMesh.new()
	mesh.size = Vector3(0.05, 0.05, 0.05)
	particles.draw_pass_1 = mesh

	return particles

func create_metal_impact() -> GPUParticles3D:
	var particles = GPUParticles3D.new()
	particles.amount = 30
	particles.lifetime = 0.3
	particles.one_shot = true
	particles.explosiveness = 1.0

	# Create particle material
	var material = ParticleProcessMaterial.new()
	material.emission_shape = ParticleProcessMaterial.EMISSION_SHAPE_SPHERE
	material.emission_sphere_radius = 0.05
	material.direction = Vector3(0, 1, 0)
	material.spread = 60.0
	material.initial_velocity_min = 2.0
	material.initial_velocity_max = 5.0
	material.gravity = Vector3(0, -9.8, 0)
	material.scale_min = 0.02
	material.scale_max = 0.05
	material.color = Color(1.0, 0.8, 0.2)  # Sparks

	particles.process_material = material

	# Create mesh
	var mesh = SphereMesh.new()
	mesh.radius = 0.02
	mesh.height = 0.04
	particles.draw_pass_1 = mesh

	return particles

func create_default_impact() -> GPUParticles3D:
	var particles = GPUParticles3D.new()
	particles.amount = 15
	particles.lifetime = 0.4
	particles.one_shot = true
	particles.explosiveness = 1.0

	# Create particle material
	var material = ParticleProcessMaterial.new()
	material.emission_shape = ParticleProcessMaterial.EMISSION_SHAPE_SPHERE
	material.emission_sphere_radius = 0.1
	material.direction = Vector3(0, 1, 0)
	material.spread = 45.0
	material.initial_velocity_min = 1.0
	material.initial_velocity_max = 2.5
	material.gravity = Vector3(0, -9.8, 0)
	material.scale_min = 0.03
	material.scale_max = 0.08
	material.color = Color(0.7, 0.7, 0.7)  # Gray dust

	particles.process_material = material

	# Create mesh
	var mesh = SphereMesh.new()
	mesh.radius = 0.03
	mesh.height = 0.06
	particles.draw_pass_1 = mesh

	return particles

func spawn_impact_effect(position: Vector3, material_type: String = "default", velocity: Vector3 = Vector3.ZERO) -> void:
	# Get the appropriate particle template
	var template = impact_particles.get(material_type, impact_particles["default"])
	var particles = template.duplicate()

	# Position and add to scene
	add_child(particles)
	particles.global_position = position

	# Adjust emission direction based on velocity
	if velocity.length() > 0.1:
		var process_mat = particles.process_material as ParticleProcessMaterial
		if process_mat:
			process_mat.direction = -velocity.normalized()

	# Start emission
	particles.emitting = true

	# Auto-cleanup after lifetime
	await get_tree().create_timer(particles.lifetime + 0.1).timeout
	if is_instance_valid(particles):
		particles.queue_free()

func spawn_dust_puff(position: Vector3, size: float = 1.0) -> void:
	var particles = GPUParticles3D.new()
	particles.amount = int(10 * size)
	particles.lifetime = 0.6
	particles.one_shot = true
	particles.explosiveness = 0.8

	# Create particle material
	var material = ParticleProcessMaterial.new()
	material.emission_shape = ParticleProcessMaterial.EMISSION_SHAPE_SPHERE
	material.emission_sphere_radius = 0.2 * size
	material.direction = Vector3(0, 1, 0)
	material.spread = 30.0
	material.initial_velocity_min = 0.5
	material.initial_velocity_max = 1.5
	material.gravity = Vector3(0, -2.0, 0)
	material.scale_min = 0.1 * size
	material.scale_max = 0.2 * size
	material.color = Color(0.8, 0.8, 0.7, 0.5)  # Light dust

	particles.process_material = material

	# Create mesh
	var mesh = SphereMesh.new()
	mesh.radius = 0.05 * size
	particles.draw_pass_1 = mesh

	# Add to scene
	add_child(particles)
	particles.global_position = position
	particles.emitting = true

	# Auto-cleanup
	await get_tree().create_timer(particles.lifetime + 0.1).timeout
	if is_instance_valid(particles):
		particles.queue_free()

func spawn_sparks(position: Vector3, direction: Vector3 = Vector3.UP) -> void:
	var particles = GPUParticles3D.new()
	particles.amount = 25
	particles.lifetime = 0.25
	particles.one_shot = true
	particles.explosiveness = 1.0

	# Create particle material
	var material = ParticleProcessMaterial.new()
	material.emission_shape = ParticleProcessMaterial.EMISSION_SHAPE_SPHERE
	material.emission_sphere_radius = 0.05
	material.direction = direction
	material.spread = 45.0
	material.initial_velocity_min = 3.0
	material.initial_velocity_max = 6.0
	material.gravity = Vector3(0, -15.0, 0)
	material.scale_min = 0.01
	material.scale_max = 0.03
	material.color = Color(1.0, 0.9, 0.3)  # Bright yellow sparks

	particles.process_material = material

	# Create mesh
	var mesh = SphereMesh.new()
	mesh.radius = 0.015
	particles.draw_pass_1 = mesh

	# Add to scene
	add_child(particles)
	particles.global_position = position
	particles.emitting = true

	# Auto-cleanup
	await get_tree().create_timer(particles.lifetime + 0.1).timeout
	if is_instance_valid(particles):
		particles.queue_free()
