extends Node3D

## Main game scene that manages the game flow and player interaction

@onready var hex_grid: HexGrid = $HexGrid
@onready var camera_controller: Node3D = $CameraController
@onready var ui: Control = $UI

var current_preview_tile: HexTile3D
var preview_coord: HexCoord
var raycast_plane: Plane = Plane(Vector3.UP, 0)

func _ready() -> void:
	# Start the game
	GameManager.start_new_game(hex_grid)

	# Connect signals
	GameManager.current_tile_changed.connect(_on_current_tile_changed)
	GameManager.game_over.connect(_on_game_over)
	GameManager.turn_advanced.connect(_on_turn_advanced)
	ScoringSystem.score_changed.connect(_on_score_changed)

	# Update UI
	_update_ui()

func _input(event: InputEvent) -> void:
	# Tile rotation
	if event.is_action_pressed("rotate_right"):
		GameManager.rotate_current_tile_clockwise()
		_update_preview()
		get_viewport().set_input_as_handled()

	if event.is_action_pressed("rotate_left"):
		GameManager.rotate_current_tile_counter_clockwise()
		_update_preview()
		get_viewport().set_input_as_handled()

	# Tile placement
	if event.is_action_pressed("place_tile"):
		if preview_coord and current_preview_tile:
			if GameManager.place_current_tile(preview_coord):
				_place_tile_visual(preview_coord, GameManager.hex_grid.get_tile(preview_coord))
				_clear_preview()
		get_viewport().set_input_as_handled()

func _process(_delta: float) -> void:
	_update_mouse_hover()

## Update the preview tile position based on mouse hover
func _update_mouse_hover() -> void:
	var mouse_pos = get_viewport().get_mouse_position()
	var camera = camera_controller.camera

	if not camera:
		return

	# Raycast from camera to mouse position
	var from = camera.project_ray_origin(mouse_pos)
	var to = from + camera.project_ray_normal(mouse_pos) * 1000

	# Intersect with ground plane
	var intersection = raycast_plane.intersects_ray(from, to - from)

	if intersection:
		# Convert world position to hex coordinate
		var hex_coord = HexCoord.from_world_position(intersection)

		# Check if this is a valid placement position
		if hex_grid.is_position_empty(hex_coord) and hex_grid.is_valid_placement_position(hex_coord):
			if not preview_coord or not preview_coord.equals(hex_coord):
				preview_coord = hex_coord
				_update_preview()
		else:
			_clear_preview()

## Update the preview tile visual
func _update_preview() -> void:
	if current_preview_tile:
		current_preview_tile.queue_free()
		current_preview_tile = null

	if not preview_coord:
		return

	var current_tile = GameManager.get_current_tile()
	if not current_tile:
		return

	# Create preview tile
	current_preview_tile = HexTile3D.new()
	hex_grid.add_child(current_preview_tile)

	var world_pos = preview_coord.to_world_position()
	current_preview_tile.position = world_pos
	current_preview_tile.setup(preview_coord, current_tile.duplicate(), true)

	# Check if placement is valid
	var is_valid = GameManager.is_valid_placement(preview_coord)
	current_preview_tile.set_valid_placement(is_valid)

## Clear the preview tile
func _clear_preview() -> void:
	if current_preview_tile:
		current_preview_tile.queue_free()
		current_preview_tile = null
	preview_coord = null

## Place a tile visually on the grid
func _place_tile_visual(coord: HexCoord, tile_data: TileData) -> void:
	var tile_node = HexTile3D.new()
	hex_grid.add_child(tile_node)

	var world_pos = coord.to_world_position()
	tile_node.position = world_pos
	tile_node.setup(coord, tile_data, false)

	# Store in grid
	hex_grid.tile_nodes[coord.hash()] = tile_node

## Callback when current tile changes
func _on_current_tile_changed(_tile: TileData) -> void:
	_update_preview()
	_update_ui()

## Callback when game is over
func _on_game_over() -> void:
	print("Game Over! Final Score: ", ScoringSystem.get_score())
	_clear_preview()
	_update_ui()

## Callback when turn advances
func _on_turn_advanced(_turn: int) -> void:
	_update_ui()

## Callback when score changes
func _on_score_changed(_new_score: int, points_gained: int) -> void:
	if points_gained > 0:
		print("+" + str(points_gained) + " points!")
	_update_ui()

## Update UI elements
func _update_ui() -> void:
	if not ui:
		return

	# Update score label
	var score_label = ui.get_node_or_null("ScoreLabel")
	if score_label:
		score_label.text = "Score: %d" % ScoringSystem.get_score()

	# Update tiles remaining label
	var tiles_label = ui.get_node_or_null("TilesLabel")
	if tiles_label:
		tiles_label.text = "Tiles: %d" % GameManager.get_tiles_remaining()

	# Update current tile info
	var tile_info = ui.get_node_or_null("TileInfo")
	if tile_info:
		var current = GameManager.get_current_tile()
		if current:
			if current.has_quest:
				tile_info.text = "Quest: %d %s tiles" % [current.quest_target, TerrainType.get_name(current.quest_type)]
			else:
				tile_info.text = "Tile ready"
		else:
			tile_info.text = "Game Over"
