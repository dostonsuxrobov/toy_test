extends Node
class_name CollisionMonitor

# The RigidBody3D this monitor is attached to
var parent_body: RigidBody3D = null

# Break threshold
@export var break_velocity: float = 15.0  # m/s
@export var material_type: String = "default"  # wood, metal, plastic

# Managers
var particle_manager: ParticleManager = null
var sound_manager: SoundManager = null

# Tracking
var is_broken: bool = false
var last_impact_time: float = 0.0
var min_impact_interval: float = 0.1  # Minimum time between impact effects

func _ready() -> void:
	# Get parent body
	parent_body = get_parent() as RigidBody3D
	if not parent_body:
		push_error("CollisionMonitor must be child of RigidBody3D")
		return

	# Connect to body signals
	parent_body.body_entered.connect(_on_body_entered)

	# Try to find managers
	var workspace = get_node_or_null("/root/Main/Workspace")
	if workspace:
		particle_manager = workspace.get_node_or_null("ParticleManager")
		sound_manager = workspace.get_node_or_null("SoundManager")

func _on_body_entered(body: Node) -> void:
	if is_broken:
		return

	# Get collision info
	var velocity = parent_body.linear_velocity.length()
	var current_time = Time.get_ticks_msec() / 1000.0

	# Check if enough time has passed since last impact
	if current_time - last_impact_time < min_impact_interval:
		return

	last_impact_time = current_time

	# Get collision point (approximate using body position)
	var collision_point = parent_body.global_position

	# Spawn effects based on velocity
	if velocity > 1.0:  # Minimum velocity for effects
		# Particle effects
		if particle_manager:
			if velocity > break_velocity:
				# Heavy impact - sparks or large dust
				if material_type == "metal":
					particle_manager.spawn_sparks(collision_point, -parent_body.linear_velocity.normalized())
				else:
					particle_manager.spawn_dust_puff(collision_point, 1.5)
			else:
				# Normal impact
				particle_manager.spawn_impact_effect(collision_point, material_type, parent_body.linear_velocity)

		# Sound effects
		if sound_manager:
			sound_manager.play_collision_sound(collision_point, velocity, material_type)

	# Check if part should break
	if velocity > break_velocity and not is_broken:
		break_part()

func break_part() -> void:
	if is_broken:
		return

	is_broken = true
	print("Part broken: ", parent_body.name)

	# Create break effect
	if particle_manager:
		particle_manager.spawn_impact_effect(parent_body.global_position, material_type, parent_body.linear_velocity * 2.0)
		particle_manager.spawn_dust_puff(parent_body.global_position, 2.0)

	# Create broken pieces (simple version - just spawn smaller cubes)
	create_broken_pieces()

	# Hide original part
	parent_body.visible = false
	parent_body.freeze = true

func create_broken_pieces() -> void:
	# Create 3-5 smaller pieces that fly off
	var num_pieces = randi_range(3, 5)

	for i in range(num_pieces):
		var piece = RigidBody3D.new()
		piece.mass = parent_body.mass / num_pieces

		# Create mesh
		var mesh_instance = MeshInstance3D.new()
		var box_mesh = BoxMesh.new()
		box_mesh.size = Vector3(0.2, 0.2, 0.2)
		mesh_instance.mesh = box_mesh

		# Copy material from parent
		var parent_mesh = parent_body.get_node_or_null("MeshInstance3D")
		if parent_mesh is MeshInstance3D:
			mesh_instance.material_override = parent_mesh.material_override

		# Add collision
		var collision = CollisionShape3D.new()
		var box_shape = BoxShape3D.new()
		box_shape.size = Vector3(0.2, 0.2, 0.2)
		collision.shape = box_shape

		piece.add_child(mesh_instance)
		piece.add_child(collision)

		# Position with random offset
		var offset = Vector3(
			randf_range(-0.3, 0.3),
			randf_range(-0.3, 0.3),
			randf_range(-0.3, 0.3)
		)
		piece.global_position = parent_body.global_position + offset

		# Add random velocity
		piece.linear_velocity = parent_body.linear_velocity + Vector3(
			randf_range(-3, 3),
			randf_range(2, 5),
			randf_range(-3, 3)
		)
		piece.angular_velocity = Vector3(
			randf_range(-5, 5),
			randf_range(-5, 5),
			randf_range(-5, 5)
		)

		# Add to scene
		parent_body.get_parent().add_child(piece)

		# Auto-cleanup after a few seconds
		await get_tree().create_timer(5.0).timeout
		if is_instance_valid(piece):
			piece.queue_free()
