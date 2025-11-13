extends Node3D

@export var rotation_speed: float = 0.005
@export var pan_speed: float = 0.01
@export var zoom_speed: float = 0.5
@export var min_zoom: float = 5.0
@export var max_zoom: float = 50.0

@onready var camera: Camera3D = $Camera3D
@onready var pivot: Node3D = $"."

var is_rotating: bool = false
var is_panning: bool = false
var last_mouse_pos: Vector2
var camera_distance: float = 20.0

func _ready():
	# Position camera at initial distance
	camera.position.z = camera_distance
	pivot.rotation.x = -0.6  # Look down at an angle

func _input(event):
	# Handle camera rotation (right mouse button)
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_RIGHT:
			is_rotating = event.pressed
			last_mouse_pos = event.position
		elif event.button_index == MOUSE_BUTTON_MIDDLE:
			is_panning = event.pressed
			last_mouse_pos = event.position
		# Handle zoom with mouse wheel
		elif event.button_index == MOUSE_BUTTON_WHEEL_UP:
			camera_distance = clamp(camera_distance - zoom_speed, min_zoom, max_zoom)
			camera.position.z = camera_distance
		elif event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
			camera_distance = clamp(camera_distance + zoom_speed, min_zoom, max_zoom)
			camera.position.z = camera_distance

	# Handle mouse motion for rotation and panning
	if event is InputEventMouseMotion:
		if is_rotating:
			var delta = event.position - last_mouse_pos
			# Rotate around Y axis (horizontal rotation)
			pivot.rotate_y(-delta.x * rotation_speed)
			# Rotate around local X axis (vertical rotation)
			var new_rotation_x = pivot.rotation.x - delta.y * rotation_speed
			# Clamp vertical rotation to prevent flipping
			pivot.rotation.x = clamp(new_rotation_x, -1.4, -0.1)
			last_mouse_pos = event.position

		elif is_panning:
			var delta = event.position - last_mouse_pos
			# Pan the camera
			var right = pivot.transform.basis.x
			var forward = Vector3(pivot.transform.basis.z.x, 0, pivot.transform.basis.z.z).normalized()
			pivot.position -= right * delta.x * pan_speed
			pivot.position += forward * delta.y * pan_speed
			last_mouse_pos = event.position

func get_camera() -> Camera3D:
	return camera
