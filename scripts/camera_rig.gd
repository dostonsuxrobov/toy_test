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
var current_rotation: Vector2 = Vector2(-30, 45)  # Look from above at 30 degrees down
var focal_point: Vector3 = Vector3(0, 0, 0)  # Center of workspace
var camera_locked: bool = false  # Always allow camera movement

func _ready() -> void:
	if game_manager:
		game_manager.state_changed.connect(_on_state_changed)
	# Start with simple centered view
	focal_point = Vector3(0, 1, 0)
	current_distance = 20.0
	current_rotation = Vector2(-30, 45)
	camera_locked = false  # Allow camera movement from start
	update_camera_position()


func _input(event: InputEvent) -> void:
	# Always allow camera controls now
	if camera_locked:
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
	camera.look_at(position, Vector3.UP)

func snap_to_last_placed(part: Node3D) -> void:
	# Snap focal point to the last placed object
	if is_instance_valid(part):
		focal_point = part.global_position
		update_camera_position()

func _on_state_changed(new_state: GameManager.GameState) -> void:
	# Camera is always free to move now
	pass
