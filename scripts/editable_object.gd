extends Node3D

# This script handles individual object editing
var is_selected = false
var original_scale = Vector3.ONE
var original_rotation = Vector3.ZERO
var building_type
var original_material: Material  # Store the original material

# Edit handles
var scale_handle_visible = false
var rotate_handle_visible = false

func _ready():
	if has_meta("building_type"):
		building_type = get_meta("building_type")
	original_scale = scale
	original_rotation = rotation_degrees

	# Store the original material
	var mesh_instance = get_node_or_null("MeshInstance3D")
	if mesh_instance and mesh_instance.material_override:
		original_material = mesh_instance.material_override

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
			# Store the current material if we haven't already
			if not original_material and mesh_instance.material_override:
				original_material = mesh_instance.material_override

			# Use a complete red material for strong visual feedback
			var selection_material = StandardMaterial3D.new()
			selection_material.albedo_color = Color(1.0, 0.0, 0.0, 1.0)  # Complete red, fully opaque
			selection_material.metallic = 0.0
			selection_material.roughness = 0.8
			mesh_instance.material_override = selection_material
		else:
			# Reset to original material
			if original_material:
				mesh_instance.material_override = original_material
