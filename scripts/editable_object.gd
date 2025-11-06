extends Node3D

# This script handles individual object editing
var is_selected = false
var original_scale = Vector3.ONE
var original_rotation = Vector3.ZERO
var building_type

# Edit handles
var scale_handle_visible = false
var rotate_handle_visible = false

func _ready():
	if has_meta("building_type"):
		building_type = get_meta("building_type")
	original_scale = scale
	original_rotation = rotation_degrees

func _input(event):
	if not is_selected:
		return

	# Delete with Delete/Backspace key
	if event is InputEventKey and event.pressed:
		if event.keycode == KEY_DELETE or event.keycode == KEY_BACKSPACE:
			queue_free()
			get_parent().placed_objects.erase(self)
			print("Object deleted")

	# Scale with + and - keys
	if event is InputEventKey and event.pressed:
		if event.keycode == KEY_EQUAL or event.keycode == KEY_PLUS:
			scale *= 1.1
			print("Scaled up")
		elif event.keycode == KEY_MINUS:
			scale *= 0.9
			print("Scaled down")

	# Rotate with Q and E keys
	if event is InputEventKey and event.pressed:
		if event.keycode == KEY_Q:
			rotation_degrees.y += 15
			print("Rotated left")
		elif event.keycode == KEY_E:
			rotation_degrees.y -= 15
			print("Rotated right")

func set_selected(selected: bool):
	is_selected = selected

	# Visual feedback for selection
	var mesh_instance = get_node_or_null("MeshInstance3D")
	if mesh_instance:
		if selected:
			# Use the same bright ghost-like material as preview
			var ghost_material = StandardMaterial3D.new()
			ghost_material.albedo_color = Color(1.0, 1.0, 1.0, 0.5)  # Bright white, semi-transparent
			ghost_material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
			mesh_instance.material_override = ghost_material
		else:
			# Reset to original material
			var main = get_parent()
			match building_type:
				main.BuildingType.LARGE_BUILDING:
					mesh_instance.material_override = main.building_material.duplicate()
				main.BuildingType.ROAD:
					mesh_instance.material_override = main.road_material.duplicate()
				main.BuildingType.LAKE:
					mesh_instance.material_override = main.lake_material.duplicate()
