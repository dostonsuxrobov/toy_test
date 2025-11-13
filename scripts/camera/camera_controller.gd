extends Node3D

## Camera controller for panning, zooming, and rotating the view

@export var camera: Camera3D
@export var pan_speed: float = 0.5
@export var zoom_speed: float = 2.0
@export var rotate_speed: float = 2.0
@export var min_zoom: float = 5.0
@export var max_zoom: float = 30.0

var camera_distance: float = 15.0
var camera_angle: float = 45.0  # Degrees from horizontal
var camera_rotation: float = 0.0  # Rotation around Y axis

var is_panning: bool = false
var last_mouse_position: Vector2

func _ready() -> void:
	if not camera:
		camera = Camera3D.new()
		add_child(camera)

	_update_camera_position()

func _input(event: InputEvent) -> void:
	# Mouse wheel for zooming
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_WHEEL_UP:
			zoom_camera(-zoom_speed)
		elif event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
			zoom_camera(zoom_speed)
		elif event.button_index == MOUSE_BUTTON_MIDDLE:
			is_panning = event.pressed
			if event.pressed:
				last_mouse_position = event.position

	# Middle mouse drag for panning
	if event is InputEventMouseMotion:
		if is_panning:
			var delta = event.position - last_mouse_position
			pan_camera(delta)
			last_mouse_position = event.position

		# Right mouse for rotation
		if Input.is_mouse_button_pressed(MOUSE_BUTTON_RIGHT):
			var delta = event.relative
			rotate_camera(delta.x * rotate_speed * 0.01)

func _process(_delta: float) -> void:
	# Keyboard camera controls
	if Input.is_key_pressed(KEY_LEFT) or Input.is_key_pressed(KEY_A):
		position.x -= pan_speed * 0.1
	if Input.is_key_pressed(KEY_RIGHT) or Input.is_key_pressed(KEY_D):
		position.x += pan_speed * 0.1
	if Input.is_key_pressed(KEY_UP) or Input.is_key_pressed(KEY_W):
		position.z -= pan_speed * 0.1
	if Input.is_key_pressed(KEY_DOWN) or Input.is_key_pressed(KEY_S):
		position.z += pan_speed * 0.1

## Zoom the camera in/out
func zoom_camera(delta: float) -> void:
	camera_distance += delta
	camera_distance = clamp(camera_distance, min_zoom, max_zoom)
	_update_camera_position()

## Pan the camera
func pan_camera(delta: Vector2) -> void:
	# Convert screen space delta to world space
	var pan_factor = camera_distance * 0.001 * pan_speed

	# Apply rotation to pan direction
	var rad = deg_to_rad(camera_rotation)
	var cos_r = cos(rad)
	var sin_r = sin(rad)

	var world_delta_x = (-delta.x * cos_r - delta.y * sin_r) * pan_factor
	var world_delta_z = (-delta.x * sin_r + delta.y * cos_r) * pan_factor

	position.x += world_delta_x
	position.z += world_delta_z

## Rotate the camera around the focal point
func rotate_camera(delta: float) -> void:
	camera_rotation += delta * rotate_speed
	_update_camera_position()

## Update camera position based on distance, angle, and rotation
func _update_camera_position() -> void:
	if not camera:
		return

	# Calculate camera position in spherical coordinates
	var rad_angle = deg_to_rad(camera_angle)
	var rad_rotation = deg_to_rad(camera_rotation)

	var y = camera_distance * sin(rad_angle)
	var horizontal_distance = camera_distance * cos(rad_angle)
	var x = horizontal_distance * sin(rad_rotation)
	var z = horizontal_distance * cos(rad_rotation)

	camera.position = Vector3(x, y, z)
	camera.look_at(Vector3.ZERO, Vector3.UP)

## Focus camera on a specific world position
func focus_on(world_position: Vector3) -> void:
	position = world_position
