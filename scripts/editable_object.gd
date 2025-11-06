extends Node3D

# This script handles individual object editing
var is_selected = false
var original_scale = Vector3.ONE
var original_rotation = Vector3.ZERO
var building_type
var original_material: Material = null
var material_stored = false

func _ready():
	print("=== EDITABLE OBJECT READY ===")
	print("Node name: ", name)
	
	if has_meta("building_type"):
		building_type = get_meta("building_type")
		print("Building type: ", building_type)
	
	original_scale = scale
	original_rotation = rotation_degrees
	
	var mesh_instance = get_node_or_null("MeshInstance3D")
	print("MeshInstance3D found: ", mesh_instance != null)
	if mesh_instance:
		print("Current material: ", mesh_instance.material_override)

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
	print("\n=== SET_SELECTED CALLED ===")
	print("Selected: ", selected)
	
	is_selected = selected
	
	var mesh_instance = get_node_or_null("MeshInstance3D")
	print("MeshInstance3D: ", mesh_instance)
	
	if not mesh_instance:
		print("ERROR: No MeshInstance3D found!")
		return
	
	if selected:
		print("Applying selection highlight...")
		
		# Store the original material the first time we select
		if not material_stored and mesh_instance.material_override:
			original_material = mesh_instance.material_override.duplicate()
			material_stored = true
			print("Stored original material: ", original_material)
		
		# Create highlight material (bright yellow with slight transparency)
		var highlight_material = StandardMaterial3D.new()
		highlight_material.albedo_color = Color(1.0, 1.0, 0.3, 1.0)  # Bright yellow
		highlight_material.emission_enabled = true
		highlight_material.emission = Color(0.8, 0.8, 0.0)  # Yellow glow
		highlight_material.emission_energy_multiplier = 0.5
		highlight_material.metallic = 0.0
		highlight_material.roughness = 0.5
		
		mesh_instance.material_override = highlight_material
		print("Applied highlight material: ", mesh_instance.material_override)
	else:
		print("Restoring original material...")
		# Restore the original material
		if original_material:
			mesh_instance.material_override = original_material.duplicate()
			print("Restored original material: ", mesh_instance.material_override)
		else:
			print("WARNING: No original material to restore!")
