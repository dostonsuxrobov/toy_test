extends Node3D

@export var rotation_speed: float = 0.5
@export var zoom_speed: float = 2.0
@export var min_distance: float = 5.0
@export var max_distance: float = 30.0
@export var pan_speed: float = 0.15

@onready var camera: Camera3D = $Camera3D
@onready var game_manager: GameManager = get_node("/root/Main/GameManager")

var is_rotating: bool = false
var is_panning: bool = false
var last_mouse_position: Vector2
var current_distance: float = 15.0
var current_rotation: Vector2 = Vector2(-45, 45)
var focal_point: Vector3 = Vector3.ZERO  # The point the camera orbits around
var camera_locked: bool = true  # Locked during BRIEFING

# Follow mode for TEST state
var follow_mode: bool = false
var follow_target: Node3D = null
var follow_smoothing: float = 5.0

func _ready() -> void:
	if game_manager:
		game_manager.state_changed.connect(_on_state_changed)
	# Start with establishing shot
	setup_establishing_shot(Vector3(-8, 3, 0), Vector3(8, 0, 0))

func setup_establishing_shot(start_point: Vector3, end_point: Vector3) -> void:
	# Calculate the midpoint between start and end
	focal_point = (start_point + end_point) / 2.0

	# Calculate distance to frame both points
	var distance_between = start_point.distance_to(end_point)
	current_distance = distance_between * 0.8  # 80% to have some margin
	current_distance = clamp(current_distance, min_distance, max_distance)

	# Set to a nice establishing angle
	current_rotation = Vector2(-35, 45)

	update_camera_position()

func _input(event: InputEvent) -> void:
	# Block camera controls during BRIEFING and in follow mode
	if camera_locked or follow_mode:
		return

	if event is InputEventMouseButton:
		# Middle mouse button for orbit/pan
		if event.button_index == MOUSE_BUTTON_MIDDLE:
			if Input.is_key_pressed(KEY_SHIFT):
				is_panning = event.pressed
			else:
				is_rotating = event.pressed
			last_mouse_position = event.position

		# Mouse wheel for zoom
		elif event.button_index == MOUSE_BUTTON_WHEEL_UP:
			current_distance = max(min_distance, current_distance - zoom_speed)
			update_camera_position()
		elif event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
			current_distance = min(max_distance, current_distance + zoom_speed)
			update_camera_position()

	# Mouse motion
	if event is InputEventMouseMotion:
		if is_rotating:
			var delta = event.position - last_mouse_position
			current_rotation.x -= delta.y * rotation_speed
			current_rotation.y -= delta.x * rotation_speed
			current_rotation.x = clamp(current_rotation.x, -89, 89)
			last_mouse_position = event.position
			update_camera_position()
		elif is_panning:
			var delta = event.position - last_mouse_position
			# Pan in screen space
			var right = camera.global_transform.basis.x
			var up = camera.global_transform.basis.y
			focal_point -= right * delta.x * pan_speed * (current_distance / 15.0)
			focal_point += up * delta.y * pan_speed * (current_distance / 15.0)
			last_mouse_position = event.position
			update_camera_position()

func _process(delta: float) -> void:
	# Update follow mode
	if follow_mode and is_instance_valid(follow_target):
		focal_point = focal_point.lerp(follow_target.global_position, delta * follow_smoothing)
		update_camera_position()

func update_camera_position() -> void:
	position = focal_point

	var rot_x = deg_to_rad(current_rotation.x)
	var rot_y = deg_to_rad(current_rotation.y)

	var offset := Vector3(
		cos(rot_x) * sin(rot_y),
		sin(rot_x),
		cos(rot_x) * cos(rot_y)
	) * current_distance

	camera.position = offset
	camera.look_at(Vector3.ZERO, Vector3.UP)

func snap_to_last_placed(part: Node3D) -> void:
	# Snap focal point to the last placed object
	if is_instance_valid(part):
		focal_point = part.global_position
		update_camera_position()

func _on_state_changed(new_state: GameManager.GameState) -> void:
	match new_state:
		GameManager.GameState.BRIEFING:
			camera_locked = true
			follow_mode = false
		GameManager.GameState.BUILD:
			camera_locked = false
			follow_mode = false
		GameManager.GameState.TEST:
			camera_locked = false
			follow_mode = true
			# Find the ball to follow
			find_follow_target()
		GameManager.GameState.REVIEW:
			follow_mode = false

func find_follow_target() -> void:
	# Find first moving rigid body (usually the ball)
	if game_manager:
		for part in game_manager.placed_parts:
			if is_instance_valid(part) and part is RigidBody3D:
				follow_target = part
				return

	# If no placed parts, look for level-provided ball
	var workspace = get_node("/root/Main/Workspace")
	if workspace:
		for child in workspace.get_children():
			if child is RigidBody3D and child.has_node("../"):
				follow_target = child
				return
