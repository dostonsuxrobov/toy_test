class_name HexTile3D
extends Node3D

## Visual representation of a hex tile in 3D

var tile_data: TileData
var hex_coord: HexCoord
var is_preview: bool = false

const HEX_SIZE = 1.0
const HEX_HEIGHT = 0.2

var mesh_instance: MeshInstance3D
var quest_marker: Node3D

func _ready() -> void:
	if tile_data:
		_create_hex_mesh()

func setup(coord: HexCoord, data: TileData, preview: bool = false) -> void:
	hex_coord = coord
	tile_data = data
	is_preview = preview

	if is_node_ready():
		_create_hex_mesh()

## Create the 3D hexagonal mesh with colored segments
func _create_hex_mesh() -> void:
	# Clear existing mesh
	if mesh_instance:
		mesh_instance.queue_free()

	mesh_instance = MeshInstance3D.new()
	add_child(mesh_instance)

	# Create the hex mesh
	var surface_tool = SurfaceTool.new()
	surface_tool.begin(Mesh.PRIMITIVE_TRIANGLES)

	# Center of hex
	var center = Vector3.ZERO

	# Calculate hex vertices (flat-top orientation)
	var vertices = []
	for i in range(6):
		var angle_deg = 60.0 * i
		var angle_rad = deg_to_rad(angle_deg)
		var x = HEX_SIZE * cos(angle_rad)
		var z = HEX_SIZE * sin(angle_rad)
		vertices.append(Vector3(x, 0, z))

	# Create top face with colored segments
	for i in range(6):
		var next_i = (i + 1) % 6

		# Get terrain color for this segment
		var terrain = tile_data.get_side_terrain(i)
		var color = TerrainType.get_color(terrain)

		# Create triangle for this segment
		# Center vertex
		surface_tool.set_color(color)
		surface_tool.set_normal(Vector3.UP)
		surface_tool.add_vertex(center)

		# Outer vertices
		surface_tool.set_color(color)
		surface_tool.set_normal(Vector3.UP)
		surface_tool.add_vertex(vertices[i])

		surface_tool.set_color(color)
		surface_tool.set_normal(Vector3.UP)
		surface_tool.add_vertex(vertices[next_i])

	# Create sides (extruded down)
	for i in range(6):
		var next_i = (i + 1) % 6

		var terrain = tile_data.get_side_terrain(i)
		var color = TerrainType.get_color(terrain)
		var darker_color = color * 0.7  # Darken sides

		var top1 = vertices[i]
		var top2 = vertices[next_i]
		var bottom1 = vertices[i] - Vector3(0, HEX_HEIGHT, 0)
		var bottom2 = vertices[next_i] - Vector3(0, HEX_HEIGHT, 0)

		# Calculate normal for this side
		var edge = top2 - top1
		var down = Vector3.DOWN
		var normal = edge.cross(down).normalized()

		# First triangle
		surface_tool.set_color(darker_color)
		surface_tool.set_normal(normal)
		surface_tool.add_vertex(top1)

		surface_tool.set_color(darker_color)
		surface_tool.set_normal(normal)
		surface_tool.add_vertex(bottom1)

		surface_tool.set_color(darker_color)
		surface_tool.set_normal(normal)
		surface_tool.add_vertex(top2)

		# Second triangle
		surface_tool.set_color(darker_color)
		surface_tool.set_normal(normal)
		surface_tool.add_vertex(top2)

		surface_tool.set_color(darker_color)
		surface_tool.set_normal(normal)
		surface_tool.add_vertex(bottom1)

		surface_tool.set_color(darker_color)
		surface_tool.set_normal(normal)
		surface_tool.add_vertex(bottom2)

	# Create bottom face
	for i in range(6):
		var next_i = (i + 1) % 6

		var terrain = tile_data.center_terrain
		var color = TerrainType.get_color(terrain) * 0.5  # Even darker bottom

		var bottom_center = Vector3(0, -HEX_HEIGHT, 0)
		var bottom1 = vertices[i] - Vector3(0, HEX_HEIGHT, 0)
		var bottom2 = vertices[next_i] - Vector3(0, HEX_HEIGHT, 0)

		surface_tool.set_color(color)
		surface_tool.set_normal(Vector3.DOWN)
		surface_tool.add_vertex(bottom_center)

		surface_tool.set_color(color)
		surface_tool.set_normal(Vector3.DOWN)
		surface_tool.add_vertex(bottom2)  # Reversed order for correct winding

		surface_tool.set_color(color)
		surface_tool.set_normal(Vector3.DOWN)
		surface_tool.add_vertex(bottom1)

	# Generate normals and create mesh
	var array_mesh = surface_tool.commit()
	mesh_instance.mesh = array_mesh

	# Create material
	var material = StandardMaterial3D.new()
	material.vertex_color_use_as_albedo = true
	material.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED if is_preview else BaseMaterial3D.SHADING_MODE_PER_VERTEX
	if is_preview:
		material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
		material.albedo_color = Color(1, 1, 1, 0.7)
	mesh_instance.set_surface_override_material(0, material)

	# Add quest marker if tile has a quest
	if tile_data.has_quest and not is_preview:
		_create_quest_marker()

## Create a visual indicator for quest tiles
func _create_quest_marker() -> void:
	quest_marker = Node3D.new()
	add_child(quest_marker)

	# Create a small flag or marker above the tile
	var marker_mesh = MeshInstance3D.new()
	quest_marker.add_child(marker_mesh)

	var cylinder = CylinderMesh.new()
	cylinder.top_radius = 0.05
	cylinder.bottom_radius = 0.05
	cylinder.height = 0.5
	marker_mesh.mesh = cylinder
	marker_mesh.position = Vector3(0, 0.25, 0)

	var material = StandardMaterial3D.new()
	material.albedo_color = Color(1, 0.8, 0)  # Golden color for quest
	material.emission_enabled = true
	material.emission = Color(1, 0.8, 0)
	marker_mesh.set_surface_override_material(0, material)

	# Add a flag shape on top
	var flag_mesh = MeshInstance3D.new()
	quest_marker.add_child(flag_mesh)

	var quad = QuadMesh.new()
	quad.size = Vector2(0.3, 0.2)
	flag_mesh.mesh = quad
	flag_mesh.position = Vector3(0.15, 0.5, 0)
	flag_mesh.rotation.y = deg_to_rad(90)

	var flag_material = StandardMaterial3D.new()
	flag_material.albedo_color = TerrainType.get_color(tile_data.quest_type)
	flag_material.emission_enabled = true
	flag_material.emission = TerrainType.get_color(tile_data.quest_type) * 0.5
	flag_mesh.set_surface_override_material(0, flag_material)

## Update visual for highlight/preview state
func set_valid_placement(is_valid: bool) -> void:
	if not mesh_instance:
		return

	var material = mesh_instance.get_surface_override_material(0)
	if material:
		if is_valid:
			material.albedo_color = Color(1, 1, 1, 0.9)
		else:
			material.albedo_color = Color(1, 0.3, 0.3, 0.7)
