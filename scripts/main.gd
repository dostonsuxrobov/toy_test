extends Node3D

# References
@onready var camera = $Camera3D
@onready var ground_plane = $Ground
@onready var ui = $UI

# Camera control variables
var camera_rotation_speed = 0.005
var camera_zoom_speed = 2.0
var camera_pan_speed = 0.01
var is_rotating = false
var is_panning = false
var last_mouse_position = Vector2.ZERO

# Camera position
var camera_distance = 15.0
var camera_angle_h = 0.0
var camera_angle_v = -45.0
var camera_target = Vector3.ZERO

# Building system
enum BuildingType { NONE, LARGE_BUILDING, ROAD, LAKE }
var current_building_type = BuildingType.NONE
var preview_object: Node3D = null
var placed_objects = []
var selected_object: Node3D = null
var is_editing = false

# Store original materials for each object
var object_materials = {}

# Materials
var building_material: StandardMaterial3D
var road_material: StandardMaterial3D
var lake_material: StandardMaterial3D
var preview_material: StandardMaterial3D

func _ready():
	setup_materials()
	update_camera_position()

func setup_materials():
	# Building material (brown/beige)
	building_material = StandardMaterial3D.new()
	building_material.albedo_color = Color(0.7, 0.5, 0.3)
	building_material.metallic = 0.0
	building_material.roughness = 0.8

	# Road material (gray)
	road_material = StandardMaterial3D.new()
	road_material.albedo_color = Color(0.3, 0.3, 0.3)
	road_material.metallic = 0.0
	road_material.roughness = 0.9

	# Lake material (blue, semi-transparent)
	lake_material = StandardMaterial3D.new()
	lake_material.albedo_color = Color(0.2, 0.5, 0.8, 0.7)
	lake_material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	lake_material.metallic = 0.5
	lake_material.roughness = 0.2

	# Preview material (semi-transparent white)
	preview_material = StandardMaterial3D.new()
	preview_material.albedo_color = Color(1.0, 1.0, 1.0, 0.5)
	preview_material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA

func _input(event):
	# Handle selected object input
	if selected_object and is_editing:
		if event is InputEventKey and event.pressed:
			# Delete with Delete/Backspace key
			if event.keycode == KEY_DELETE or event.keycode == KEY_BACKSPACE:
				delete_selected_object()
				return
			# Scale with + and - keys
			elif event.keycode == KEY_EQUAL or event.keycode == KEY_PLUS:
				selected_object.scale *= 1.1
				print("Scaled up")
				return
			elif event.keycode == KEY_MINUS:
				selected_object.scale *= 0.9
				print("Scaled down")
				return
			# Rotate with Q and E keys
			elif event.keycode == KEY_Q:
				selected_object.rotation_degrees.y += 15
				print("Rotated left")
				return
			elif event.keycode == KEY_E:
				selected_object.rotation_degrees.y -= 15
				print("Rotated right")
				return

	# Camera rotation with middle mouse button
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_MIDDLE:
			if event.shift_pressed:
				is_panning = event.pressed
			else:
				is_rotating = event.pressed
			last_mouse_position = event.position
		# Zoom with scroll wheel
		elif event.button_index == MOUSE_BUTTON_WHEEL_UP:
			camera_distance = max(5.0, camera_distance - camera_zoom_speed)
			update_camera_position()
		elif event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
			camera_distance = min(50.0, camera_distance + camera_zoom_speed)
			update_camera_position()
		# Left click for placing/selecting
		elif event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
			handle_left_click()
		# Right click to deselect
		elif event.button_index == MOUSE_BUTTON_RIGHT and event.pressed:
			if current_building_type != BuildingType.NONE:
				set_building_type(BuildingType.NONE)
				print("Placement mode cancelled")
			elif selected_object:
				deselect_object()

	# ESC key to deselect
	if event is InputEventKey and event.pressed and event.keycode == KEY_ESCAPE:
		if current_building_type != BuildingType.NONE:
			set_building_type(BuildingType.NONE)
			print("Placement mode cancelled")
		elif selected_object:
			deselect_object()

	# Mouse motion for camera control
	if event is InputEventMouseMotion:
		if is_rotating:
			var delta = event.position - last_mouse_position
			camera_angle_h -= delta.x * camera_rotation_speed
			camera_angle_v = clamp(camera_angle_v - delta.y * camera_rotation_speed, -89.0, -10.0)
			update_camera_position()
			last_mouse_position = event.position
		elif is_panning:
			var delta = event.position - last_mouse_position
			var right = camera.global_transform.basis.x
			var forward = Vector3(camera.global_transform.basis.z.x, 0, camera.global_transform.basis.z.z).normalized()
			camera_target -= right * delta.x * camera_pan_speed * camera_distance * 0.01
			camera_target += forward * delta.y * camera_pan_speed * camera_distance * 0.01
			update_camera_position()
			last_mouse_position = event.position

func _process(delta):
	update_preview()

func update_camera_position():
	var h_rad = deg_to_rad(camera_angle_h)
	var v_rad = deg_to_rad(camera_angle_v)

	var x = camera_distance * cos(v_rad) * sin(h_rad)
	var y = camera_distance * sin(v_rad)
	var z = camera_distance * cos(v_rad) * cos(h_rad)

	camera.position = camera_target + Vector3(x, -y, z)
	camera.look_at(camera_target, Vector3.UP)

func set_building_type(type: BuildingType):
	current_building_type = type
	deselect_object()

	# Clear any existing preview
	if preview_object:
		preview_object.queue_free()
		preview_object = null

func update_preview():
	if current_building_type == BuildingType.NONE:
		if preview_object:
			preview_object.queue_free()
			preview_object = null
		return

	var mouse_pos = get_viewport().get_mouse_position()
	var from = camera.project_ray_origin(mouse_pos)
	var to = from + camera.project_ray_normal(mouse_pos) * 1000

	var space_state = get_world_3d().direct_space_state
	var query = PhysicsRayQueryParameters3D.create(from, to)
	query.collision_mask = 1
	var result = space_state.intersect_ray(query)

	if result:
		if not preview_object:
			preview_object = create_building_mesh(current_building_type, true)
			add_child(preview_object)

		preview_object.position = result.position
		preview_object.position.y = get_building_height(current_building_type) / 2

func handle_left_click():
	if current_building_type == BuildingType.NONE:
		# Try to select an existing object
		select_object_at_mouse()
	else:
		# Place new object
		place_building()

func select_object_at_mouse():
	var mouse_pos = get_viewport().get_mouse_position()
	var from = camera.project_ray_origin(mouse_pos)
	var to = from + camera.project_ray_normal(mouse_pos) * 1000

	var space_state = get_world_3d().direct_space_state
	var query = PhysicsRayQueryParameters3D.create(from, to)
	query.collision_mask = 2  # Objects layer
	var result = space_state.intersect_ray(query)

	# Deselect previous object first
	if selected_object:
		restore_original_material(selected_object)

	if result and result.collider:
		var obj = result.collider.get_parent()
		if obj in placed_objects:
			selected_object = obj
			is_editing = true
			apply_highlight_material(selected_object)
			print("Selected object for editing. Use +/- to scale, Q/E to rotate, Delete to remove")
		else:
			selected_object = null
			is_editing = false
	else:
		selected_object = null
		is_editing = false

func deselect_object():
	if selected_object:
		restore_original_material(selected_object)
	selected_object = null
	is_editing = false
	print("Object deselected")

func delete_selected_object():
	if selected_object:
		placed_objects.erase(selected_object)
		object_materials.erase(selected_object)
		selected_object.queue_free()
		selected_object = null
		is_editing = false
		print("Object deleted")

func apply_highlight_material(obj: Node3D):
	var mesh_instance = obj.get_node_or_null("MeshInstance3D")
	
	if mesh_instance and mesh_instance.material_override:
		# Store original material if not already stored
		if not obj in object_materials:
			object_materials[obj] = mesh_instance.material_override.duplicate()
		
		# Create bright highlight material
		var highlight_material = StandardMaterial3D.new()
		highlight_material.albedo_color = Color(1.0, 1.0, 0.3, 1.0)  # Bright yellow
		highlight_material.emission_enabled = true
		highlight_material.emission = Color(0.8, 0.8, 0.0)
		highlight_material.emission_energy_multiplier = 0.5
		highlight_material.metallic = 0.0
		highlight_material.roughness = 0.5
		
		mesh_instance.material_override = highlight_material

func restore_original_material(obj: Node3D):
	var mesh_instance = obj.get_node_or_null("MeshInstance3D")
	if mesh_instance and obj in object_materials:
		mesh_instance.material_override = object_materials[obj].duplicate()

func place_building():
	if not preview_object:
		return

	var new_building = create_building_mesh(current_building_type, false)
	new_building.position = preview_object.position
	add_child(new_building)
	placed_objects.append(new_building)

	print("Placed ", get_building_name(current_building_type))

func create_building_mesh(type: BuildingType, is_preview: bool) -> Node3D:
	var container = Node3D.new()
	var mesh_instance = MeshInstance3D.new()
	var collision_shape = CollisionShape3D.new()
	var static_body = StaticBody3D.new()

	# IMPORTANT: Give the mesh instance a name so we can find it later
	mesh_instance.name = "MeshInstance3D"

	match type:
		BuildingType.LARGE_BUILDING:
			var box = BoxMesh.new()
			box.size = Vector3(4, 6, 4)
			mesh_instance.mesh = box

			var shape = BoxShape3D.new()
			shape.size = Vector3(4, 6, 4)
			collision_shape.shape = shape

			if is_preview:
				mesh_instance.material_override = preview_material
			else:
				mesh_instance.material_override = building_material.duplicate()

		BuildingType.ROAD:
			var box = BoxMesh.new()
			box.size = Vector3(6, 0.2, 2)
			mesh_instance.mesh = box

			var shape = BoxShape3D.new()
			shape.size = Vector3(6, 0.2, 2)
			collision_shape.shape = shape

			if is_preview:
				mesh_instance.material_override = preview_material
			else:
				mesh_instance.material_override = road_material.duplicate()

		BuildingType.LAKE:
			var box = BoxMesh.new()
			box.size = Vector3(8, 0.5, 8)
			mesh_instance.mesh = box

			var shape = BoxShape3D.new()
			shape.size = Vector3(8, 0.5, 8)
			collision_shape.shape = shape

			if is_preview:
				mesh_instance.material_override = preview_material
			else:
				mesh_instance.material_override = lake_material.duplicate()

	container.add_child(mesh_instance)

	if not is_preview:
		static_body.collision_layer = 2
		static_body.collision_mask = 0
		static_body.add_child(collision_shape)
		container.add_child(static_body)

		# Store metadata
		container.set_meta("building_type", type)
		container.set_meta("editable", true)

	return container

func get_building_height(type: BuildingType) -> float:
	match type:
		BuildingType.LARGE_BUILDING:
			return 6.0
		BuildingType.ROAD:
			return 0.2
		BuildingType.LAKE:
			return 0.5
	return 0.0

func get_building_name(type: BuildingType) -> String:
	match type:
		BuildingType.LARGE_BUILDING:
			return "Large Building"
		BuildingType.ROAD:
			return "Road"
		BuildingType.LAKE:
			return "Lake"
	return "Unknown"

# Called by UI buttons
func _on_building_button_pressed():
	set_building_type(BuildingType.LARGE_BUILDING)

func _on_road_button_pressed():
	set_building_type(BuildingType.ROAD)

func _on_lake_button_pressed():
	set_building_type(BuildingType.LAKE)

func _on_clear_button_pressed():
	set_building_type(BuildingType.NONE)
