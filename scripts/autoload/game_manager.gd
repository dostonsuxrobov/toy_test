extends Node

## Main game manager that coordinates all game systems

signal turn_advanced(turn_number: int)
signal current_tile_changed(tile: TileData)
signal game_over()

var hex_grid: HexGrid
var tile_generator: TileGenerator
var current_tile: TileData
var turn_count: int = 0
var tiles_remaining: int = 50  # Standard game length

var game_active: bool = false

func _ready() -> void:
	tile_generator = TileGenerator.new()

func start_new_game(grid: HexGrid) -> void:
	hex_grid = grid
	turn_count = 0
	tiles_remaining = 50
	game_active = true

	# Reset scoring
	ScoringSystem.reset_score()

	# Clear the grid
	hex_grid.clear_grid()

	# Generate first tile
	generate_next_tile()

	# Connect signals
	hex_grid.tile_placed.connect(_on_tile_placed)
	hex_grid.perfect_placement.connect(_on_perfect_placement)

## Generate the next tile for the player to place
func generate_next_tile() -> void:
	if tiles_remaining <= 0:
		game_active = false
		game_over.emit()
		return

	# Randomly decide if this should be a quest tile
	var should_have_quest = randf() < 0.15  # 15% chance

	if should_have_quest and tiles_remaining > 10:  # Don't give quests near end of game
		var quest_terrain = _get_random_terrain_type()
		var quest_target = randi_range(5, 12)
		current_tile = tile_generator.generate_quest_tile(quest_terrain, quest_target)
	else:
		current_tile = tile_generator.generate_tile()

	current_tile_changed.emit(current_tile)

## Attempt to place the current tile
func place_current_tile(coord: HexCoord) -> bool:
	if not game_active:
		return false

	if not current_tile:
		return false

	# Validate placement
	if not hex_grid.check_valid_placement(coord, current_tile):
		return false

	# Place the tile
	if hex_grid.place_tile(coord, current_tile):
		# Calculate and add score
		var points = ScoringSystem.calculate_placement_score(hex_grid, coord, current_tile)
		ScoringSystem.add_score(points)

		# Advance turn
		turn_count += 1
		tiles_remaining -= 1
		turn_advanced.emit(turn_count)

		# Generate next tile
		generate_next_tile()

		return true

	return false

## Rotate current tile clockwise
func rotate_current_tile_clockwise() -> void:
	if current_tile:
		current_tile.rotate_clockwise()
		current_tile_changed.emit(current_tile)

## Rotate current tile counter-clockwise
func rotate_current_tile_counter_clockwise() -> void:
	if current_tile:
		current_tile.rotate_counter_clockwise()
		current_tile_changed.emit(current_tile)

## Check if a position is valid for the current tile
func is_valid_placement(coord: HexCoord) -> bool:
	if not current_tile:
		return false
	return hex_grid.check_valid_placement(coord, current_tile)

## Get current tile
func get_current_tile() -> TileData:
	return current_tile

## Get tiles remaining
func get_tiles_remaining() -> int:
	return tiles_remaining

## Callback when tile is placed
func _on_tile_placed(coord: HexCoord, tile: TileData) -> void:
	print("Tile placed at ", coord, " - Score: ", ScoringSystem.get_score())

## Callback when perfect placement achieved
func _on_perfect_placement(coord: HexCoord) -> void:
	print("Perfect placement at ", coord, "! +", ScoringSystem.PERFECT_PLACEMENT_BONUS, " bonus points!")

## Helper to get random terrain type
func _get_random_terrain_type() -> TerrainType.Type:
	var terrains = [
		TerrainType.Type.FIELD,
		TerrainType.Type.FOREST,
		TerrainType.Type.VILLAGE,
		TerrainType.Type.WATER,
		TerrainType.Type.RAILWAY
	]
	return terrains[randi_range(0, terrains.size() - 1)]
