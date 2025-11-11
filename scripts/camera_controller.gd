extends Camera2D
class_name CameraController

# Camera controls: drag with middle/right mouse, zoom with wheel

var is_dragging: bool = false
var drag_start_pos: Vector2 = Vector2.ZERO
var camera_start_pos: Vector2 = Vector2.ZERO

@export var zoom_min: float = 0.3
@export var zoom_max: float = 2.0
@export var zoom_speed: float = 0.1

func _ready():
	position = Vector2(640, 360)
	zoom = Vector2(1.0, 1.0)

func _input(event):
	# Handle zoom
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_WHEEL_UP:
			zoom_camera(zoom_speed)
			get_viewport().set_input_as_handled()
		elif event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
			zoom_camera(-zoom_speed)
			get_viewport().set_input_as_handled()

		# Handle drag start
		elif event.button_index == MOUSE_BUTTON_MIDDLE or event.button_index == MOUSE_BUTTON_RIGHT:
			if event.pressed:
				is_dragging = true
				drag_start_pos = get_viewport().get_mouse_position()
				camera_start_pos = position
				get_viewport().set_input_as_handled()
			else:
				is_dragging = false
				get_viewport().set_input_as_handled()

	# Handle drag motion
	if event is InputEventMouseMotion and is_dragging:
		var mouse_pos = get_viewport().get_mouse_position()
		var delta = (drag_start_pos - mouse_pos) / zoom.x
		position = camera_start_pos + delta
		get_viewport().set_input_as_handled()

func zoom_camera(amount: float):
	var new_zoom = zoom.x + amount
	new_zoom = clamp(new_zoom, zoom_min, zoom_max)
	zoom = Vector2(new_zoom, new_zoom)
