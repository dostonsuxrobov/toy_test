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
@export var wall_snap_enabled: bool = true  # TinyGlade-style wall snapping
@export var snap_radius: float = 1.5  # Radius for snapping to endpoints
@export var min_wall_length: float = 0.5  # Minimum wall length

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

# Wall endpoint tracking (TinyGlade-style)
var wall_endpoints: Array[Vector3] = []  # All wall endpoints for snapping
var wall_segments: Array[Dictionary] = []  # Stores {start: Vector3, end: Vector3, wall: Node3D}
var snap_indicator: Node3D = null  # Visual feedback for snap points
var current_snap_point: Vector3 = Vector3.ZERO  # Currently snapped point

func _ready():
	create_snap_indicator()

func create_snap_indicator():
	"""Create visual feedback for snap points"""
	snap_indicator = Node3D.new()
	var mesh_instance = MeshInstance3D.new()
	var sphere_mesh = SphereMesh.new()
	sphere_mesh.radius = 0.2
	sphere_mesh.height = 0.4
	mesh_instance.mesh = sphere_mesh

	var material = StandardMaterial3D.new()
	material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	material.albedo_color = Color(0.3, 1.0, 0.3, 0.8)  # Green indicator
	material.emission_enabled = true
	material.emission = Color(0.3, 1.0, 0.3)
	material.emission_energy = 2.0
	mesh_instance.material_override = material

	snap_indicator.add_child(mesh_instance)
	snap_indicator.visible = false
	add_child(snap_indicator)

func find_snap_point(pos: Vector3, ignore_ctrl: bool = true) -> Vector3:
	"""Find nearest snap point within snap_radius (TinyGlade-style)"""
	if not wall_snap_enabled:
		return pos

	# Check if Ctrl is held (disables snapping like in TinyGlade)
	if ignore_ctrl and Input.is_key_pressed(KEY_CTRL):
		return pos

	var nearest_point = pos
	var nearest_dist = snap_radius

	# Check all wall endpoints
	for endpoint in wall_endpoints:
		var dist = pos.distance_to(endpoint)
		if dist < nearest_dist:
			nearest_dist = dist
			nearest_point = endpoint

	return nearest_point

func apply_angle_constraint(start: Vector3, end: Vector3) -> Vector3:
	"""Constrain wall angle to 45/90 degrees (TinyGlade feature request)"""
	# Shift key activates angle snapping (like TinyGlade users requested)
	if not Input.is_key_pressed(KEY_SHIFT):
		return end

	var direction = end - start
	var angle = atan2(direction.z, direction.x)
	var length = direction.length()

	# Snap to nearest 45-degree angle
	var snap_angle = round(angle / (PI / 4.0)) * (PI / 4.0)

	var snapped_end = start + Vector3(
		cos(snap_angle) * length,
		0,
		sin(snap_angle) * length
	)

	return snapped_end

func update_snap_indicator(pos: Vector3):
	"""Update visual feedback for snap point"""
	if not snap_indicator:
		return

	var snapped = find_snap_point(pos)
	var is_snapping = snapped.distance_to(pos) > 0.01

	snap_indicator.visible = is_snapping
	if is_snapping:
		snap_indicator.position = snapped
		current_snap_point = snapped
	else:
		current_snap_point = Vector3.ZERO

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
	# Apply TinyGlade-style snapping
	var snapped_pos = find_snap_point(world_pos)
	update_snap_indicator(world_pos)

	# Apply angle constraints if enabled
	if has_wall_start:
		snapped_pos = apply_angle_constraint(last_wall_point, snapped_pos)

	if not has_wall_start:
		# Show a starting point indicator
		if not preview_piece:
			preview_piece = create_wall_preview()
			add_child(preview_piece)
		preview_piece.position = snapped_pos
	else:
		# Check minimum wall length
		var wall_length = last_wall_point.distance_to(snapped_pos)
		if wall_length < min_wall_length * 0.5:  # Lower threshold for preview
			if preview_piece:
				preview_piece.visible = false
			return

		# Show wall from last point to current point
		if preview_piece:
			preview_piece.queue_free()
		preview_piece = create_wall_between_points(last_wall_point, snapped_pos, true)
		preview_piece.visible = true
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
	# Apply TinyGlade-style snapping
	var snapped_pos = find_snap_point(world_pos)

	if not has_wall_start:
		# Set the starting point
		last_wall_point = snapped_pos
		has_wall_start = true

		# Add to endpoints if not already present
		if not wall_endpoints.has(snapped_pos):
			wall_endpoints.append(snapped_pos)
	else:
		# Apply angle constraints if enabled
		snapped_pos = apply_angle_constraint(last_wall_point, snapped_pos)

		# Check minimum wall length
		var wall_length = last_wall_point.distance_to(snapped_pos)
		if wall_length < min_wall_length:
			print("Wall too short! Minimum length is ", min_wall_length)
			return

		# Create wall between points
		var wall = create_wall_between_points(last_wall_point, snapped_pos, false)
		add_child(wall)
		placed_pieces.append(wall)

		# Track wall segment
		var segment = {
			"start": last_wall_point,
			"end": snapped_pos,
			"wall": wall
		}
		wall_segments.append(segment)

		# Add endpoints
		if not wall_endpoints.has(last_wall_point):
			wall_endpoints.append(last_wall_point)
		if not wall_endpoints.has(snapped_pos):
			wall_endpoints.append(snapped_pos)

		# Continue from this point
		last_wall_point = snapped_pos

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
		# Remove from wall segments and endpoints if it's a wall
		for i in range(wall_segments.size() - 1, -1, -1):
			if wall_segments[i].wall == closest_piece:
				var segment = wall_segments[i]
				wall_segments.remove_at(i)

				# Clean up endpoints that are no longer connected to any wall
				cleanup_orphaned_endpoints(segment.start)
				cleanup_orphaned_endpoints(segment.end)

		placed_pieces.erase(closest_piece)
		closest_piece.queue_free()

func cleanup_orphaned_endpoints(endpoint: Vector3):
	"""Remove endpoint if no wall segments use it"""
	var is_used = false
	for segment in wall_segments:
		if segment.start.distance_to(endpoint) < 0.01 or segment.end.distance_to(endpoint) < 0.01:
			is_used = true
			break

	if not is_used:
		for i in range(wall_endpoints.size() - 1, -1, -1):
			if wall_endpoints[i].distance_to(endpoint) < 0.01:
				wall_endpoints.remove_at(i)
				break

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
	if snap_indicator:
		snap_indicator.visible = false
	current_snap_point = Vector3.ZERO

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
