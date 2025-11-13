extends Node3D

enum BuildMode {
	WALL,
	TOWER,
	GATE,
	PATH,
	DELETE
}

@export var current_mode: BuildMode = BuildMode.WALL
@export var grid_snap: bool = false
@export var snap_distance: float = 0.5

var camera: Camera3D
var terrain: Node3D
var preview_piece: Node3D = null
var placed_pieces: Array[Node3D] = []
var is_dragging: bool = false
var drag_start_pos: Vector3
var current_wall_segments: Array[Node3D] = []

# Wall building state
var last_wall_point: Vector3
var has_wall_start: bool = false

func _ready():
	pass

func set_camera(cam: Camera3D):
	camera = cam

func set_terrain(terr: Node3D):
	terrain = terr

func set_build_mode(mode: BuildMode):
	current_mode = mode
	# Clean up preview
	if preview_piece:
		preview_piece.queue_free()
		preview_piece = null

func _input(event):
	if not camera:
		return

	if event is InputEventMouseMotion:
		update_preview(event.position)

	elif event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
			handle_placement(event.position)

func update_preview(mouse_pos: Vector2):
	var world_pos = get_world_position(mouse_pos)
	if world_pos == Vector3.ZERO:
		return

	if grid_snap:
		world_pos = snap_to_grid(world_pos)

	match current_mode:
		BuildMode.WALL:
			update_wall_preview(world_pos)
		BuildMode.TOWER:
			update_tower_preview(world_pos)
		BuildMode.GATE:
			update_gate_preview(world_pos)

func update_wall_preview(world_pos: Vector3):
	if not has_wall_start:
		# Show a starting point indicator
		if not preview_piece:
			preview_piece = create_wall_preview()
			add_child(preview_piece)
		preview_piece.position = world_pos
	else:
		# Show wall from last point to current point
		if preview_piece:
			preview_piece.queue_free()
		preview_piece = create_wall_between_points(last_wall_point, world_pos, true)
		add_child(preview_piece)

func update_tower_preview(world_pos: Vector3):
	if not preview_piece:
		preview_piece = create_tower_preview()
		add_child(preview_piece)
	preview_piece.position = world_pos

func update_gate_preview(world_pos: Vector3):
	if not preview_piece:
		preview_piece = create_gate_preview()
		add_child(preview_piece)
	preview_piece.position = world_pos

func handle_placement(mouse_pos: Vector2):
	var world_pos = get_world_position(mouse_pos)
	if world_pos == Vector3.ZERO:
		return

	if grid_snap:
		world_pos = snap_to_grid(world_pos)

	match current_mode:
		BuildMode.WALL:
			place_wall(world_pos)
		BuildMode.TOWER:
			place_tower(world_pos)
		BuildMode.GATE:
			place_gate(world_pos)
		BuildMode.DELETE:
			delete_at_position(world_pos)

func place_wall(world_pos: Vector3):
	if not has_wall_start:
		# Set the starting point
		last_wall_point = world_pos
		has_wall_start = true
	else:
		# Create wall between points
		var wall = create_wall_between_points(last_wall_point, world_pos, false)
		add_child(wall)
		placed_pieces.append(wall)
		# Continue from this point
		last_wall_point = world_pos

func place_tower(world_pos: Vector3):
	var tower = create_tower_piece()
	tower.position = world_pos
	add_child(tower)
	placed_pieces.append(tower)

func place_gate(world_pos: Vector3):
	var gate = create_gate_piece()
	gate.position = world_pos
	add_child(gate)
	placed_pieces.append(gate)

func delete_at_position(world_pos: Vector3):
	# Find closest piece and delete it
	var closest_piece: Node3D = null
	var closest_dist: float = 2.0  # Maximum deletion distance

	for piece in placed_pieces:
		var dist = piece.position.distance_to(world_pos)
		if dist < closest_dist:
			closest_dist = dist
			closest_piece = piece

	if closest_piece:
		placed_pieces.erase(closest_piece)
		closest_piece.queue_free()

func get_world_position(mouse_pos: Vector2) -> Vector3:
	var from = camera.project_ray_origin(mouse_pos)
	var dir = camera.project_ray_normal(mouse_pos)

	# Raycast to terrain (y = 0 plane for now)
	var plane = Plane(Vector3.UP, 0)
	var intersection = plane.intersects_ray(from, dir)

	if intersection:
		return intersection
	return Vector3.ZERO

func snap_to_grid(pos: Vector3) -> Vector3:
	return Vector3(
		round(pos.x / snap_distance) * snap_distance,
		pos.y,
		round(pos.z / snap_distance) * snap_distance
	)

# Building piece creation functions
func create_wall_preview() -> Node3D:
	var wall = Node3D.new()
	var mesh_instance = MeshInstance3D.new()
	var box_mesh = BoxMesh.new()
	box_mesh.size = Vector3(0.3, 3, 0.3)
	mesh_instance.mesh = box_mesh

	var material = StandardMaterial3D.new()
	material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	material.albedo_color = Color(0.8, 0.8, 0.9, 0.5)
	mesh_instance.material_override = material

	wall.add_child(mesh_instance)
	mesh_instance.position.y = 1.5
	return wall

func create_wall_between_points(start: Vector3, end: Vector3, is_preview: bool) -> Node3D:
	var wall = Node3D.new()
	var mesh_instance = MeshInstance3D.new()

	var length = start.distance_to(end)
	var box_mesh = BoxMesh.new()
	box_mesh.size = Vector3(0.3, 3, length)
	mesh_instance.mesh = box_mesh

	var material = StandardMaterial3D.new()
	if is_preview:
		material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
		material.albedo_color = Color(0.8, 0.8, 0.9, 0.5)
	else:
		material.albedo_color = Color(0.7, 0.65, 0.6)
		material.roughness = 0.8
	mesh_instance.material_override = material

	wall.add_child(mesh_instance)

	# Position and rotate the wall
	var midpoint = (start + end) / 2.0
	wall.position = midpoint
	mesh_instance.position.y = 1.5

	# Rotate to face the correct direction
	var direction = (end - start).normalized()
	if direction.length() > 0.01:
		wall.look_at(end, Vector3.UP)
		wall.rotate_y(PI / 2)

	return wall

func create_tower_preview() -> Node3D:
	return create_tower_piece(true)

func create_tower_piece(is_preview: bool = false) -> Node3D:
	var tower = Node3D.new()
	var mesh_instance = MeshInstance3D.new()
	var cylinder_mesh = CylinderMesh.new()
	cylinder_mesh.height = 5
	cylinder_mesh.top_radius = 0.8
	cylinder_mesh.bottom_radius = 1.0
	mesh_instance.mesh = cylinder_mesh

	var material = StandardMaterial3D.new()
	if is_preview:
		material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
		material.albedo_color = Color(0.8, 0.8, 0.9, 0.5)
	else:
		material.albedo_color = Color(0.65, 0.6, 0.55)
		material.roughness = 0.8
	mesh_instance.material_override = material

	tower.add_child(mesh_instance)
	mesh_instance.position.y = 2.5

	# Add roof
	var roof = MeshInstance3D.new()
	var cone_mesh = CylinderMesh.new()
	cone_mesh.height = 1.5
	cone_mesh.top_radius = 0.1
	cone_mesh.bottom_radius = 1.0
	roof.mesh = cone_mesh

	var roof_material = StandardMaterial3D.new()
	if is_preview:
		roof_material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
		roof_material.albedo_color = Color(0.6, 0.3, 0.3, 0.5)
	else:
		roof_material.albedo_color = Color(0.5, 0.2, 0.2)
	roof.material_override = roof_material

	tower.add_child(roof)
	roof.position.y = 5.75

	return tower

func create_gate_preview() -> Node3D:
	return create_gate_piece(true)

func create_gate_piece(is_preview: bool = false) -> Node3D:
	var gate = Node3D.new()

	# Left pillar
	var left_pillar = MeshInstance3D.new()
	var box_mesh_left = BoxMesh.new()
	box_mesh_left.size = Vector3(0.5, 4, 0.5)
	left_pillar.mesh = box_mesh_left
	left_pillar.position = Vector3(-1.5, 2, 0)

	# Right pillar
	var right_pillar = MeshInstance3D.new()
	var box_mesh_right = BoxMesh.new()
	box_mesh_right.size = Vector3(0.5, 4, 0.5)
	right_pillar.mesh = box_mesh_right
	right_pillar.position = Vector3(1.5, 2, 0)

	# Top arch
	var arch = MeshInstance3D.new()
	var box_mesh_arch = BoxMesh.new()
	box_mesh_arch.size = Vector3(3, 0.5, 0.5)
	arch.mesh = box_mesh_arch
	arch.position = Vector3(0, 4, 0)

	var material = StandardMaterial3D.new()
	if is_preview:
		material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
		material.albedo_color = Color(0.8, 0.8, 0.9, 0.5)
	else:
		material.albedo_color = Color(0.7, 0.65, 0.6)
		material.roughness = 0.8

	left_pillar.material_override = material
	right_pillar.material_override = material
	arch.material_override = material

	gate.add_child(left_pillar)
	gate.add_child(right_pillar)
	gate.add_child(arch)

	return gate

func clear_wall_chain():
	has_wall_start = false
	if preview_piece:
		preview_piece.queue_free()
		preview_piece = null

func get_save_data() -> Dictionary:
	var pieces_data = []
	for piece in placed_pieces:
		if piece.has_method("get_piece_data"):
			pieces_data.append(piece.get_piece_data())
	return {"pieces": pieces_data}

func load_from_data(data: Dictionary):
	# Clear existing pieces
	for piece in placed_pieces:
		piece.queue_free()
	placed_pieces.clear()

	# Load pieces
	if data.has("pieces"):
		for piece_data in data.pieces:
			var piece = BuildingPiece.from_data(piece_data)
			add_child(piece)
			placed_pieces.append(piece)
