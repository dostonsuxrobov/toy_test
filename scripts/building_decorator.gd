extends Node3D

# Adds procedural decorations to buildings like windows, doors, banners, etc.

func add_decorations_to_wall(wall: Node3D):
	if not wall:
		return

	# Get wall dimensions
	var mesh_instance = null
	for child in wall.get_children():
		if child is MeshInstance3D:
			mesh_instance = child
			break

	if not mesh_instance or not mesh_instance.mesh is BoxMesh:
		return

	var box_mesh: BoxMesh = mesh_instance.mesh
	var wall_length = box_mesh.size.z
	var wall_height = box_mesh.size.y

	# Add windows at regular intervals
	var num_windows = max(1, int(wall_length / 3.0))
	var window_spacing = wall_length / (num_windows + 1)

	for i in range(num_windows):
		var window = create_window()
		wall.add_child(window)

		var z_offset = -wall_length / 2.0 + window_spacing * (i + 1)
		window.position = Vector3(0.2, wall_height * 0.5, z_offset)

func add_decorations_to_tower(tower: Node3D):
	if not tower:
		return

	# Add windows around the tower
	var num_windows = 4
	for i in range(num_windows):
		var window = create_window()
		tower.add_child(window)

		var angle = (i / float(num_windows)) * TAU
		var radius = 0.9
		var x = cos(angle) * radius
		var z = sin(angle) * radius

		window.position = Vector3(x, 3.0, z)
		window.look_at(tower.position + Vector3(x * 2, 3.0, z * 2), Vector3.UP)

	# Add flag on top
	var flag = create_flag()
	tower.add_child(flag)
	flag.position = Vector3(0, 6.5, 0)

func create_window() -> Node3D:
	var window = Node3D.new()

	# Window frame
	var frame = MeshInstance3D.new()
	var frame_mesh = BoxMesh.new()
	frame_mesh.size = Vector3(0.05, 0.8, 0.6)
	frame.mesh = frame_mesh

	var frame_material = StandardMaterial3D.new()
	frame_material.albedo_color = Color(0.3, 0.3, 0.35)
	frame.material_override = frame_material

	window.add_child(frame)

	# Window glass
	var glass = MeshInstance3D.new()
	var glass_mesh = BoxMesh.new()
	glass_mesh.size = Vector3(0.02, 0.6, 0.4)
	glass.mesh = glass_mesh

	var glass_material = StandardMaterial3D.new()
	glass_material.albedo_color = Color(0.5, 0.7, 0.9, 0.3)
	glass_material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	glass.material_override = glass_material

	window.add_child(glass)

	return window

func create_flag() -> Node3D:
	var flag = Node3D.new()

	# Flag pole
	var pole = MeshInstance3D.new()
	var pole_mesh = CylinderMesh.new()
	pole_mesh.height = 1.5
	pole_mesh.top_radius = 0.05
	pole_mesh.bottom_radius = 0.05
	pole.mesh = pole_mesh

	var pole_material = StandardMaterial3D.new()
	pole_material.albedo_color = Color(0.4, 0.35, 0.3)
	pole.material_override = pole_material

	flag.add_child(pole)
	pole.position.y = 0.75

	# Flag cloth
	var cloth = MeshInstance3D.new()
	var cloth_mesh = BoxMesh.new()
	cloth_mesh.size = Vector3(0.02, 0.5, 0.7)
	cloth.mesh = cloth_mesh

	var cloth_material = StandardMaterial3D.new()
	cloth_material.albedo_color = Color(0.8, 0.2, 0.2)
	cloth.material_override = cloth_material

	flag.add_child(cloth)
	cloth.position = Vector3(0, 1.25, 0.35)

	return flag

func create_door(height: float = 2.5) -> Node3D:
	var door = Node3D.new()

	# Door frame
	var frame_left = MeshInstance3D.new()
	var frame_mesh_left = BoxMesh.new()
	frame_mesh_left.size = Vector3(0.1, height, 0.1)
	frame_left.mesh = frame_mesh_left
	frame_left.position = Vector3(-0.5, height / 2, 0)

	var frame_right = MeshInstance3D.new()
	var frame_mesh_right = BoxMesh.new()
	frame_mesh_right.size = Vector3(0.1, height, 0.1)
	frame_right.mesh = frame_mesh_right
	frame_right.position = Vector3(0.5, height / 2, 0)

	var frame_top = MeshInstance3D.new()
	var frame_mesh_top = BoxMesh.new()
	frame_mesh_top.size = Vector3(1.0, 0.1, 0.1)
	frame_top.mesh = frame_mesh_top
	frame_top.position = Vector3(0, height, 0)

	# Door
	var door_mesh = MeshInstance3D.new()
	var mesh = BoxMesh.new()
	mesh.size = Vector3(0.8, height - 0.2, 0.15)
	door_mesh.mesh = mesh
	door_mesh.position = Vector3(0, (height - 0.2) / 2 + 0.1, 0)

	var door_material = StandardMaterial3D.new()
	door_material.albedo_color = Color(0.35, 0.25, 0.2)
	door_mesh.material_override = door_material

	var frame_material = StandardMaterial3D.new()
	frame_material.albedo_color = Color(0.3, 0.3, 0.35)
	frame_left.material_override = frame_material
	frame_right.material_override = frame_material
	frame_top.material_override = frame_material

	door.add_child(frame_left)
	door.add_child(frame_right)
	door.add_child(frame_top)
	door.add_child(door_mesh)

	return door
