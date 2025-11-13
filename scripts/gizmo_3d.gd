extends Node3D
class_name Gizmo3D

# Gizmo mode
enum GizmoMode { MOVE, ROTATE }
var current_mode: GizmoMode = GizmoMode.MOVE

# Target object
var target_object: Node3D = null

# Gizmo components
var move_arrows: Dictionary = {}  # Stores arrow meshes for move mode
var rotate_rings: Dictionary = {}  # Stores ring meshes for rotate mode

# Interaction state
var is_dragging: bool = false
var drag_axis: String = ""  # "x", "y", "z"
var drag_start_pos: Vector3
var drag_start_mouse: Vector2
var drag_start_rotation: Vector3

# Snapping
@export var move_snap_size: float = 1.0
@export var rotate_snap_degrees: float = 45.0
var snapping_enabled: bool = true

# Colors
var color_x: Color = Color(1.0, 0.2, 0.2)  # Red
var color_y: Color = Color(0.2, 1.0, 0.2)  # Green
var color_z: Color = Color(0.2, 0.2, 1.0)  # Blue
var color_highlight: Color = Color(1.0, 1.0, 0.0)  # Yellow for hover

# Sizes
@export var arrow_length: float = 1.5
@export var arrow_radius: float = 0.05
@export var ring_radius: float = 1.2
@export var ring_thickness: float = 0.05

func _ready() -> void:
	create_gizmo_meshes()
	update_visibility()

func create_gizmo_meshes() -> void:
	# Create move arrows
	create_move_arrow("x", Vector3.RIGHT, color_x)
	create_move_arrow("y", Vector3.UP, color_y)
	create_move_arrow("z", Vector3.BACK, color_z)

	# Create rotate rings
	create_rotate_ring("x", Vector3.RIGHT, color_x)
	create_rotate_ring("y", Vector3.UP, color_y)
	create_rotate_ring("z", Vector3.BACK, color_z)

func create_move_arrow(axis: String, direction: Vector3, color: Color) -> void:
	var container = Node3D.new()
	container.name = "Arrow_" + axis

	# Shaft (cylinder)
	var shaft = MeshInstance3D.new()
	var shaft_mesh = CylinderMesh.new()
	shaft_mesh.top_radius = arrow_radius
	shaft_mesh.bottom_radius = arrow_radius
	shaft_mesh.height = arrow_length * 0.7
	shaft.mesh = shaft_mesh

	var shaft_mat = StandardMaterial3D.new()
	shaft_mat.albedo_color = color
	shaft_mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	shaft.material_override = shaft_mat

	# Head (cone)
	var head = MeshInstance3D.new()
	var head_mesh = CylinderMesh.new()
	head_mesh.top_radius = 0.0
	head_mesh.bottom_radius = arrow_radius * 3
	head_mesh.height = arrow_length * 0.3
	head.mesh = head_mesh

	var head_mat = StandardMaterial3D.new()
	head_mat.albedo_color = color
	head_mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	head.material_override = head_mat

	# Position components
	if direction == Vector3.RIGHT:
		shaft.rotation.z = deg_to_rad(-90)
		shaft.position = direction * arrow_length * 0.35
		head.rotation.z = deg_to_rad(-90)
		head.position = direction * arrow_length * 0.85
	elif direction == Vector3.UP:
		shaft.position = direction * arrow_length * 0.35
		head.position = direction * arrow_length * 0.85
	elif direction == Vector3.BACK:
		shaft.rotation.x = deg_to_rad(90)
		shaft.position = direction * arrow_length * 0.35
		head.rotation.x = deg_to_rad(90)
		head.position = direction * arrow_length * 0.85

	container.add_child(shaft)
	container.add_child(head)
	add_child(container)

	move_arrows[axis] = {"container": container, "shaft": shaft, "head": head, "color": color}

func create_rotate_ring(axis: String, normal: Vector3, color: Color) -> void:
	var ring = MeshInstance3D.new()
	ring.name = "Ring_" + axis

	# Create torus mesh
	var torus_mesh = TorusMesh.new()
	torus_mesh.inner_radius = ring_radius - ring_thickness
	torus_mesh.outer_radius = ring_radius
	torus_mesh.rings = 32
	torus_mesh.ring_segments = 8
	ring.mesh = torus_mesh

	var ring_mat = StandardMaterial3D.new()
	ring_mat.albedo_color = color
	ring_mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	ring_mat.albedo_color.a = 0.7
	ring_mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	ring.material_override = ring_mat

	# Orient ring based on axis
	if normal == Vector3.RIGHT:
		ring.rotation.y = deg_to_rad(90)
	elif normal == Vector3.UP:
		# Already correct orientation
		pass
	elif normal == Vector3.BACK:
		ring.rotation.x = deg_to_rad(90)

	add_child(ring)
	ring.visible = false  # Hidden by default (shown in rotate mode)

	rotate_rings[axis] = {"mesh": ring, "color": color}

func set_target(obj: Node3D) -> void:
	target_object = obj
	if is_instance_valid(target_object):
		global_position = target_object.global_position
		visible = true
	else:
		visible = false

func update_visibility() -> void:
	# Show/hide components based on mode
	for axis in move_arrows:
		move_arrows[axis].container.visible = (current_mode == GizmoMode.MOVE)

	for axis in rotate_rings:
		rotate_rings[axis].mesh.visible = (current_mode == GizmoMode.ROTATE)

func _input(event: InputEvent) -> void:
	if not visible or not is_instance_valid(target_object):
		return

	# Toggle snapping with CTRL
	if event is InputEventKey:
		if event.keycode == KEY_CTRL:
			snapping_enabled = not event.pressed

	# Mouse button handling
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT:
			if event.pressed:
				start_drag(event.position)
			else:
				end_drag()

	# Mouse motion handling
	if event is InputEventMouseMotion:
		if is_dragging:
			update_drag(event.position)

func start_drag(mouse_pos: Vector2) -> void:
	var camera = get_viewport().get_camera_3d()
	if not camera:
		return

	# Raycast to find which axis was clicked
	var from = camera.project_ray_origin(mouse_pos)
	var to = from + camera.project_ray_normal(mouse_pos) * 1000

	var clicked_axis = get_clicked_axis(from, to)
	if clicked_axis != "":
		is_dragging = true
		drag_axis = clicked_axis
		drag_start_pos = target_object.global_position
		drag_start_mouse = mouse_pos
		drag_start_rotation = target_object.rotation
		print("Started dragging axis: ", drag_axis)

func end_drag() -> void:
	if is_dragging:
		is_dragging = false
		drag_axis = ""
		print("Ended drag")

func update_drag(mouse_pos: Vector2) -> void:
	if not is_dragging or not is_instance_valid(target_object):
		return

	var camera = get_viewport().get_camera_3d()
	if not camera:
		return

	if current_mode == GizmoMode.MOVE:
		update_move_drag(mouse_pos, camera)
	elif current_mode == GizmoMode.ROTATE:
		update_rotate_drag(mouse_pos, camera)

	# Update gizmo position to follow target
	global_position = target_object.global_position

func update_move_drag(mouse_pos: Vector2, camera: Camera3D) -> void:
	var delta = mouse_pos - drag_start_mouse

	# Convert screen delta to world delta along the drag axis
	var axis_vector = Vector3.ZERO
	match drag_axis:
		"x": axis_vector = Vector3.RIGHT
		"y": axis_vector = Vector3.UP
		"z": axis_vector = Vector3.BACK

	# Project axis onto screen
	var screen_center = camera.unproject_position(drag_start_pos)
	var screen_axis_end = camera.unproject_position(drag_start_pos + axis_vector)
	var screen_axis = (screen_axis_end - screen_center).normalized()

	# Calculate movement along axis
	var movement = screen_axis.dot(delta) * 0.01

	# Apply movement
	var new_pos = drag_start_pos + axis_vector * movement

	# Apply snapping
	if snapping_enabled:
		new_pos.x = round(new_pos.x / move_snap_size) * move_snap_size
		new_pos.y = round(new_pos.y / move_snap_size) * move_snap_size
		new_pos.z = round(new_pos.z / move_snap_size) * move_snap_size

	target_object.global_position = new_pos

func update_rotate_drag(mouse_pos: Vector2, camera: Camera3D) -> void:
	var delta = mouse_pos - drag_start_mouse

	# Simple rotation based on mouse delta
	var rotation_amount = delta.x * 0.01  # Radians

	# Apply snapping
	if snapping_enabled:
		var degrees = rad_to_deg(rotation_amount)
		degrees = round(degrees / rotate_snap_degrees) * rotate_snap_degrees
		rotation_amount = deg_to_rad(degrees)

	# Apply rotation
	var new_rotation = drag_start_rotation
	match drag_axis:
		"x": new_rotation.x += rotation_amount
		"y": new_rotation.y += rotation_amount
		"z": new_rotation.z += rotation_amount

	target_object.rotation = new_rotation

func get_clicked_axis(ray_from: Vector3, ray_to: Vector3) -> String:
	# Simple distance-based detection
	var ray_dir = (ray_to - ray_from).normalized()

	var closest_dist = INF
	var closest_axis = ""

	for axis in move_arrows.keys() if current_mode == GizmoMode.MOVE else rotate_rings.keys():
		var axis_pos = global_position
		var axis_vector = Vector3.ZERO

		match axis:
			"x": axis_vector = Vector3.RIGHT
			"y": axis_vector = Vector3.UP
			"z": axis_vector = Vector3.BACK

		# Calculate distance from ray to axis line
		var to_point = axis_pos - ray_from
		var projected = to_point.dot(ray_dir)
		var closest_point = ray_from + ray_dir * projected
		var dist = closest_point.distance_to(axis_pos)

		if dist < closest_dist and dist < 0.5:  # 0.5 unit threshold
			closest_dist = dist
			closest_axis = axis

	return closest_axis

func _process(_delta: float) -> void:
	# Update position to follow target
	if is_instance_valid(target_object) and not is_dragging:
		global_position = target_object.global_position
