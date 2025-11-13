extends Node3D

var path_decals: Array[Decal] = []
var camera: Camera3D

func set_camera(cam: Camera3D):
	camera = cam

func _input(event):
	if not camera:
		return

	# Paint path on left click while holding Shift
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
			if Input.is_key_pressed(KEY_SHIFT):
				paint_path_at_mouse(event.position)

func paint_path_at_mouse(mouse_pos: Vector2):
	var world_pos = get_world_position(mouse_pos)
	if world_pos != Vector3.ZERO:
		create_path_decal(world_pos)

func create_path_decal(position: Vector3):
	# Create a simple mesh for the path
	var path_mesh = MeshInstance3D.new()
	var plane_mesh = PlaneMesh.new()
	plane_mesh.size = Vector2(1.5, 1.5)
	path_mesh.mesh = plane_mesh

	var material = StandardMaterial3D.new()
	material.albedo_color = Color(0.5, 0.4, 0.3)  # Brown path color
	path_mesh.material_override = material

	path_mesh.position = position + Vector3(0, 0.01, 0)  # Slightly above ground
	path_mesh.rotation.x = -PI / 2  # Rotate to be horizontal

	add_child(path_mesh)

func get_world_position(mouse_pos: Vector2) -> Vector3:
	if not camera:
		return Vector3.ZERO

	var from = camera.project_ray_origin(mouse_pos)
	var dir = camera.project_ray_normal(mouse_pos)

	var plane = Plane(Vector3.UP, 0)
	var intersection = plane.intersects_ray(from, dir)

	if intersection:
		return intersection
	return Vector3.ZERO
