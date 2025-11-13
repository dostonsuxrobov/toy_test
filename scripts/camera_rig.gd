extends Node3D

@export var rotation_speed: float = 0.5
@export var zoom_speed: float = 2.0
@export var min_distance: float = 5.0
@export var max_distance: float = 30.0
@export var pan_speed: float = 0.01

@onready var camera: Camera3D = $Camera3D

var is_rotating: bool = false
var is_panning: bool = false
var last_mouse_position: Vector2
var current_distance: float = 15.0
var current_rotation: Vector2 = Vector2(-45, 45)
var target_position: Vector3 = Vector3.ZERO

func _ready() -> void:
	update_camera_position()

func _input(event: InputEvent) -> void:
	# Middle mouse button for rotation
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_MIDDLE:
			is_rotating = event.pressed
			last_mouse_position = event.position
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

func _process(_delta: float) -> void:
	# Keyboard controls for panning
	var pan_input := Vector2.ZERO
	if Input.is_key_pressed(KEY_A):
		pan_input.x -= 1
	if Input.is_key_pressed(KEY_D):
		pan_input.x += 1
	if Input.is_key_pressed(KEY_W):
		pan_input.y += 1
	if Input.is_key_pressed(KEY_S):
		pan_input.y -= 1

	if pan_input.length() > 0:
		pan_input = pan_input.normalized()
		var pan_delta = Vector3(pan_input.x, 0, pan_input.y) * 0.2
		target_position += pan_delta
		update_camera_position()

func update_camera_position() -> void:
	position = target_position

	var rot_x = deg_to_rad(current_rotation.x)
	var rot_y = deg_to_rad(current_rotation.y)

	var offset := Vector3(
		cos(rot_x) * sin(rot_y),
		sin(rot_x),
		cos(rot_x) * cos(rot_y)
	) * current_distance

	camera.position = offset
	camera.look_at(Vector3.ZERO, Vector3.UP)
