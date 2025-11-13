extends Node3D
class_name Workspace

@export var grid_size: float = 1.0
@export var workspace_size: Vector3 = Vector3(20, 10, 20)

@onready var game_manager: GameManager = get_node("/root/Main/GameManager")
@onready var camera_rig: Node3D = $CameraRig

var selected_part_type: String = ""
var ghost_part: Node3D = null
var can_place: bool = false
var grid_indicator: MeshInstance3D = null  # Visual feedback for placement
var gizmo: Gizmo3D = null  # 3D gizmo for editing placed parts
var selected_part: Node3D = null  # Currently selected part for editing

func _ready() -> void:
	create_grid_floor()
	create_gizmo()

func create_gizmo() -> void:
	# Load and create the gizmo
	var gizmo_script = load("res://scripts/gizmo_3d.gd")
	gizmo = gizmo_script.new()
	add_child(gizmo)
	gizmo.visible = false

func _process(_delta: float) -> void:
	if game_manager.current_state != GameManager.GameState.BUILD:
		if ghost_part:
			ghost_part.visible = false
		return

	if selected_part_type and ghost_part:
		update_ghost_position()

func _input(event: InputEvent) -> void:
	# Only allow building in BUILD mode
	if game_manager.current_state != GameManager.GameState.BUILD:
		return

	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
			if can_place and ghost_part:
				place_part()
			elif not selected_part_type:
				# Try to select a part with gizmo
				try_select_part_at_mouse()
		elif event.button_index == MOUSE_BUTTON_RIGHT and event.pressed:
			if ghost_part and selected_part_type:
				# Rotate ghost with RMB
				ghost_part.rotate_y(deg_to_rad(90))
			else:
				cancel_placement()

	# Toggle gizmo mode with G (move) and R (rotate)
	if event is InputEventKey and event.pressed and not event.echo:
		if event.keycode == KEY_G and gizmo and gizmo.visible:
			gizmo.current_mode = Gizmo3D.GizmoMode.MOVE
			gizmo.update_visibility()
		elif event.keycode == KEY_DELETE and selected_part:
			delete_selected_part()

	# Rotate ghost part with Q, E, and R keys
	if event is InputEventKey and event.pressed:
		if event.keycode == KEY_Q and ghost_part:
			ghost_part.rotate_y(deg_to_rad(45))
		elif event.keycode == KEY_E and ghost_part:
			ghost_part.rotate_y(deg_to_rad(-45))
		elif event.keycode == KEY_R and ghost_part:
			# R key for 90-degree rotation
			ghost_part.rotate_y(deg_to_rad(90))

func create_grid_floor() -> void:
	# Create a visual grid on the floor
	var mesh_instance := MeshInstance3D.new()
	var plane_mesh := PlaneMesh.new()
	plane_mesh.size = Vector2(workspace_size.x, workspace_size.z)
	mesh_instance.mesh = plane_mesh

	# Create material with grid pattern
	var material := StandardMaterial3D.new()
	material.albedo_color = Color(0.3, 0.5, 0.7, 1.0)
	material.metallic = 0.0
	material.roughness = 0.8
	mesh_instance.material_override = material

	add_child(mesh_instance)
	mesh_instance.position = Vector3(0, -0.01, 0)

	# Add collision for the floor
	var static_body := StaticBody3D.new()
	var collision_shape := CollisionShape3D.new()
	var box_shape := BoxShape3D.new()
	box_shape.size = Vector3(workspace_size.x, 0.1, workspace_size.z)
	collision_shape.shape = box_shape
	static_body.add_child(collision_shape)
	add_child(static_body)
	static_body.position = Vector3(0, -0.5, 0)

func select_part(part_type: String) -> void:
	selected_part_type = part_type
	if ghost_part:
		ghost_part.queue_free()
	if grid_indicator:
		grid_indicator.queue_free()

	ghost_part = create_ghost_part(part_type)
	add_child(ghost_part)

	# Create grid indicator for placement feedback
	grid_indicator = MeshInstance3D.new()
	var plane_mesh = PlaneMesh.new()
	plane_mesh.size = Vector2(1, 1)
	grid_indicator.mesh = plane_mesh

	var indicator_mat = StandardMaterial3D.new()
	indicator_mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	indicator_mat.albedo_color = Color(0.2, 0.5, 1.0, 0.5)  # Blue by default
	indicator_mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	grid_indicator.material_override = indicator_mat

	add_child(grid_indicator)
	grid_indicator.position.y = 0.01  # Slightly above ground

func create_ghost_part(part_type: String) -> Node3D:
	var ghost: Node3D
	match part_type:
		"ball":
			ghost = create_ball_ghost()
		"ramp":
			ghost = create_ramp_ghost()
		"domino":
			ghost = create_domino_ghost()
		"button":
			ghost = create_button_ghost()
		"lever":
			ghost = create_lever_ghost()
		_:
			ghost = Node3D.new()

	# Make it semi-transparent
	for child in ghost.get_children():
		if child is MeshInstance3D:
			var mat = child.get_active_material(0)
			if mat:
				mat = mat.duplicate()
				mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
				mat.albedo_color.a = 0.5
				child.set_surface_override_material(0, mat)

	return ghost

func create_ball_ghost() -> Node3D:
	var mesh_instance := MeshInstance3D.new()
	var sphere_mesh := SphereMesh.new()
	sphere_mesh.radius = 0.3
	sphere_mesh.height = 0.6
	mesh_instance.mesh = sphere_mesh

	var material := StandardMaterial3D.new()
	material.albedo_color = Color(0.2, 0.5, 1.0)
	mesh_instance.material_override = material

	return mesh_instance

func create_ramp_ghost() -> Node3D:
	var container := Node3D.new()
	var mesh_instance := MeshInstance3D.new()
	var box_mesh := BoxMesh.new()
	box_mesh.size = Vector3(2, 0.1, 1)
	mesh_instance.mesh = box_mesh

	var material := StandardMaterial3D.new()
	material.albedo_color = Color(0.7, 0.5, 0.3)
	mesh_instance.material_override = material

	container.add_child(mesh_instance)
	mesh_instance.rotation.z = deg_to_rad(-20)
	mesh_instance.position.y = 0.5

	return container

func create_domino_ghost() -> Node3D:
	var mesh_instance := MeshInstance3D.new()
	var box_mesh := BoxMesh.new()
	box_mesh.size = Vector3(0.1, 1, 0.5)
	mesh_instance.mesh = box_mesh

	var material := StandardMaterial3D.new()
	material.albedo_color = Color(0.9, 0.2, 0.2)
	mesh_instance.material_override = material

	return mesh_instance

func create_button_ghost() -> Node3D:
	var container := Node3D.new()

	# Base
	var base := MeshInstance3D.new()
	var base_mesh := BoxMesh.new()
	base_mesh.size = Vector3(1, 0.2, 1)
	base.mesh = base_mesh
	var base_mat := StandardMaterial3D.new()
	base_mat.albedo_color = Color(0.4, 0.4, 0.4)
	base.material_override = base_mat
	container.add_child(base)

	# Button
	var button := MeshInstance3D.new()
	var button_mesh := CylinderMesh.new()
	button_mesh.top_radius = 0.3
	button_mesh.bottom_radius = 0.3
	button_mesh.height = 0.2
	button.mesh = button_mesh
	var button_mat := StandardMaterial3D.new()
	button_mat.albedo_color = Color(1.0, 0.2, 0.2)
	button.material_override = button_mat
	container.add_child(button)
	button.position.y = 0.2

	return container

func create_lever_ghost() -> Node3D:
	var container := Node3D.new()

	# Base
	var base := MeshInstance3D.new()
	var base_mesh := CylinderMesh.new()
	base_mesh.top_radius = 0.2
	base_mesh.bottom_radius = 0.2
	base_mesh.height = 0.5
	base.mesh = base_mesh
	var base_mat := StandardMaterial3D.new()
	base_mat.albedo_color = Color(0.3, 0.6, 0.3)
	base.material_override = base_mat
	container.add_child(base)

	# Lever arm
	var arm := MeshInstance3D.new()
	var arm_mesh := BoxMesh.new()
	arm_mesh.size = Vector3(2, 0.1, 0.1)
	arm.mesh = arm_mesh
	var arm_mat := StandardMaterial3D.new()
	arm_mat.albedo_color = Color(0.4, 0.7, 0.4)
	arm.material_override = arm_mat
	container.add_child(arm)
	arm.position.y = 0.25

	return container

func update_ghost_position() -> void:
	var camera = get_viewport().get_camera_3d()
	if not camera:
		return

	var mouse_pos = get_viewport().get_mouse_position()
	var from = camera.project_ray_origin(mouse_pos)
	var to = from + camera.project_ray_normal(mouse_pos) * 1000

	var space_state = get_world_3d().direct_space_state
	var query = PhysicsRayQueryParameters3D.create(from, to)
	var result = space_state.intersect_ray(query)

	if result:
		var pos = result.position
		# Snap to grid
		pos.x = round(pos.x / grid_size) * grid_size
		pos.y = max(0, round(pos.y / grid_size) * grid_size)
		pos.z = round(pos.z / grid_size) * grid_size

		ghost_part.position = pos
		ghost_part.visible = true

		# Check if placement is valid
		can_place = is_valid_placement(pos)

		# Update grid indicator
		if grid_indicator:
			grid_indicator.position = Vector3(pos.x, 0.01, pos.z)
			grid_indicator.visible = true

			# Change color based on validity
			var mat = grid_indicator.material_override as StandardMaterial3D
			if can_place:
				mat.albedo_color = Color(0.2, 0.5, 1.0, 0.5)  # Blue for valid
			else:
				mat.albedo_color = Color(1.0, 0.2, 0.2, 0.5)  # Red for invalid
	else:
		ghost_part.visible = false
		if grid_indicator:
			grid_indicator.visible = false
		can_place = false

func is_valid_placement(pos: Vector3) -> bool:
	# Check if within workspace bounds
	if abs(pos.x) > workspace_size.x / 2 or pos.y > workspace_size.y or abs(pos.z) > workspace_size.z / 2:
		return false
	return true

func place_part() -> void:
	if not can_place or not ghost_part:
		return

	var pos = ghost_part.position
	var rot = ghost_part.rotation
	var actual_part = create_actual_part(selected_part_type, pos)
	if actual_part:
		actual_part.rotation = rot
		add_child(actual_part)
		var cost = get_part_cost(selected_part_type)
		game_manager.add_part(actual_part, cost)

func try_select_part_at_mouse() -> void:
	var camera = get_viewport().get_camera_3d()
	if not camera:
		return

	var mouse_pos = get_viewport().get_mouse_position()
	var from = camera.project_ray_origin(mouse_pos)
	var to = from + camera.project_ray_normal(mouse_pos) * 1000

	var space_state = get_world_3d().direct_space_state
	var query = PhysicsRayQueryParameters3D.create(from, to)
	var result = space_state.intersect_ray(query)

	if result and result.collider:
		var collider = result.collider
		# Find the root part node
		var part_node = collider
		while part_node and part_node.get_parent() != self:
			part_node = part_node.get_parent()

		if part_node and part_node in game_manager.placed_parts:
			# Select this part and show gizmo
			selected_part = part_node
			if gizmo:
				gizmo.set_target(selected_part)
				print("Selected part: ", selected_part.name)
		else:
			# Deselect
			deselect_part()
	else:
		# Clicked on nothing - deselect
		deselect_part()

func deselect_part() -> void:
	selected_part = null
	if gizmo:
		gizmo.visible = false

func delete_selected_part() -> void:
	if selected_part and selected_part in game_manager.placed_parts:
		var cost = get_part_cost_from_node(selected_part)
		game_manager.remove_part(selected_part, cost)
		deselect_part()

func get_part_cost_from_node(node: Node3D) -> int:
	# Try to determine part type from node structure
	if node is RigidBody3D:
		for child in node.get_children():
			if child is MeshInstance3D:
				var mesh = child.mesh
				if mesh is SphereMesh:
					return 50  # Ball
				elif mesh is BoxMesh:
					var size = mesh.size
					if size.x < 0.2:
						return 25  # Domino
					else:
						return 150  # Lever
	elif node is StaticBody3D:
		return 100  # Ramp
	return 0

func create_actual_part(part_type: String, pos: Vector3) -> Node3D:
	var part: Node3D
	match part_type:
		"ball":
			part = create_ball_part()
		"ramp":
			part = create_ramp_part()
		"domino":
			part = create_domino_part()
		"button":
			part = create_button_part()
		"lever":
			part = create_lever_part()
		_:
			return null

	part.position = pos
	return part

func create_ball_part() -> RigidBody3D:
	var body := RigidBody3D.new()
	body.mass = 1.0
	body.freeze = true

	var mesh_instance := MeshInstance3D.new()
	var sphere_mesh := SphereMesh.new()
	sphere_mesh.radius = 0.3
	sphere_mesh.height = 0.6
	mesh_instance.mesh = sphere_mesh

	var material := StandardMaterial3D.new()
	material.albedo_color = Color(0.2, 0.5, 1.0)
	mesh_instance.material_override = material

	var collision := CollisionShape3D.new()
	var sphere_shape := SphereShape3D.new()
	sphere_shape.radius = 0.3
	collision.shape = sphere_shape

	body.add_child(mesh_instance)
	body.add_child(collision)

	return body

func create_ramp_part() -> StaticBody3D:
	var body := StaticBody3D.new()

	var mesh_instance := MeshInstance3D.new()
	var box_mesh := BoxMesh.new()
	box_mesh.size = Vector3(2, 0.1, 1)
	mesh_instance.mesh = box_mesh

	var material := StandardMaterial3D.new()
	material.albedo_color = Color(0.7, 0.5, 0.3)
	mesh_instance.material_override = material

	var collision := CollisionShape3D.new()
	var box_shape := BoxShape3D.new()
	box_shape.size = Vector3(2, 0.1, 1)
	collision.shape = box_shape

	body.add_child(mesh_instance)
	body.add_child(collision)

	mesh_instance.rotation.z = deg_to_rad(-20)
	collision.rotation.z = deg_to_rad(-20)
	mesh_instance.position.y = 0.5
	collision.position.y = 0.5

	return body

func create_domino_part() -> RigidBody3D:
	var body := RigidBody3D.new()
	body.mass = 0.5
	body.freeze = true

	var mesh_instance := MeshInstance3D.new()
	var box_mesh := BoxMesh.new()
	box_mesh.size = Vector3(0.1, 1, 0.5)
	mesh_instance.mesh = box_mesh

	var material := StandardMaterial3D.new()
	material.albedo_color = Color(0.9, 0.2, 0.2)
	mesh_instance.material_override = material

	var collision := CollisionShape3D.new()
	var box_shape := BoxShape3D.new()
	box_shape.size = Vector3(0.1, 1, 0.5)
	collision.shape = box_shape

	body.add_child(mesh_instance)
	body.add_child(collision)

	return body

func create_button_part() -> Area3D:
	var area := Area3D.new()
	area.set_script(load("res://scripts/goal_button.gd"))

	# Base
	var base_body := StaticBody3D.new()
	var base := MeshInstance3D.new()
	var base_mesh := BoxMesh.new()
	base_mesh.size = Vector3(1, 0.2, 1)
	base.mesh = base_mesh
	var base_mat := StandardMaterial3D.new()
	base_mat.albedo_color = Color(0.4, 0.4, 0.4)
	base.material_override = base_mat

	var base_collision := CollisionShape3D.new()
	var base_shape := BoxShape3D.new()
	base_shape.size = Vector3(1, 0.2, 1)
	base_collision.shape = base_shape

	base_body.add_child(base)
	base_body.add_child(base_collision)
	area.add_child(base_body)

	# Button trigger area
	var button := MeshInstance3D.new()
	var button_mesh := CylinderMesh.new()
	button_mesh.top_radius = 0.3
	button_mesh.bottom_radius = 0.3
	button_mesh.height = 0.2
	button.mesh = button_mesh
	var button_mat := StandardMaterial3D.new()
	button_mat.albedo_color = Color(1.0, 0.2, 0.2)
	button.material_override = button_mat
	button.position.y = 0.2
	area.add_child(button)

	var trigger := CollisionShape3D.new()
	var trigger_shape := CylinderShape3D.new()
	trigger_shape.radius = 0.3
	trigger_shape.height = 0.3
	trigger.shape = trigger_shape
	trigger.position.y = 0.2
	area.add_child(trigger)

	return area

func create_lever_part() -> RigidBody3D:
	var body := RigidBody3D.new()
	body.mass = 2.0
	body.freeze = true

	# Base
	var base := MeshInstance3D.new()
	var base_mesh := CylinderMesh.new()
	base_mesh.top_radius = 0.2
	base_mesh.bottom_radius = 0.2
	base_mesh.height = 0.5
	base.mesh = base_mesh
	var base_mat := StandardMaterial3D.new()
	base_mat.albedo_color = Color(0.3, 0.6, 0.3)
	base.material_override = base_mat

	var base_collision := CollisionShape3D.new()
	var base_shape := CylinderShape3D.new()
	base_shape.radius = 0.2
	base_shape.height = 0.5
	base_collision.shape = base_shape

	# Lever arm
	var arm := MeshInstance3D.new()
	var arm_mesh := BoxMesh.new()
	arm_mesh.size = Vector3(2, 0.1, 0.1)
	arm.mesh = arm_mesh
	var arm_mat := StandardMaterial3D.new()
	arm_mat.albedo_color = Color(0.4, 0.7, 0.4)
	arm.material_override = arm_mat
	arm.position.y = 0.25

	var arm_collision := CollisionShape3D.new()
	var arm_shape := BoxShape3D.new()
	arm_shape.size = Vector3(2, 0.1, 0.1)
	arm_collision.shape = arm_shape
	arm_collision.position.y = 0.25

	body.add_child(base)
	body.add_child(base_collision)
	body.add_child(arm)
	body.add_child(arm_collision)

	return body

func get_part_cost(part_type: String) -> int:
	match part_type:
		"ball":
			return 50
		"ramp":
			return 100
		"domino":
			return 25
		"button":
			return 0  # Goal, no cost
		"lever":
			return 150
		_:
			return 0

func cancel_placement() -> void:
	selected_part_type = ""
	if ghost_part:
		ghost_part.queue_free()
		ghost_part = null
	if grid_indicator:
		grid_indicator.queue_free()
		grid_indicator = null
	can_place = false
