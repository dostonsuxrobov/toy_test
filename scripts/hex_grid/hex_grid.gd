class_name HexGrid
extends Node3D

## Manages the hexagonal grid, placed tiles, and placement validation

signal tile_placed(coord: HexCoord, tile: TileData)
signal perfect_placement(coord: HexCoord)

const HEX_SIZE = 1.0

# Dictionary mapping HexCoord hash -> TileData
var placed_tiles: Dictionary = {}
# Dictionary mapping HexCoord hash -> Node3D (the visual tile)
var tile_nodes: Dictionary = {}

func _ready() -> void:
	pass

## Check if a position is empty
func is_position_empty(coord: HexCoord) -> bool:
	return not placed_tiles.has(coord.hash())

## Check if a position is valid for placement (has at least one neighbor)
func is_valid_placement_position(coord: HexCoord) -> bool:
	# First tile can be placed anywhere
	if placed_tiles.is_empty():
		return true

	# Otherwise, must have at least one neighbor
	var neighbors = coord.get_all_neighbors()
	for neighbor in neighbors:
		if not is_position_empty(neighbor):
			return true
	return false

## Get tile at coordinate
func get_tile(coord: HexCoord) -> TileData:
	return placed_tiles.get(coord.hash())

## Place a tile at the given coordinate
func place_tile(coord: HexCoord, tile: TileData) -> bool:
	if not is_position_empty(coord):
		return false

	if not is_valid_placement_position(coord):
		return false

	# Store the tile
	placed_tiles[coord.hash()] = tile

	# Check if placement is perfect (all sides match)
	var is_perfect = check_perfect_placement(coord, tile)
	tile.is_perfect = is_perfect

	# Emit signals
	tile_placed.emit(coord, tile)
	if is_perfect:
		perfect_placement.emit(coord)

	return true

## Check if a tile placement would be valid (all adjacent sides match)
func check_valid_placement(coord: HexCoord, tile: TileData) -> bool:
	# First tile is always valid
	if placed_tiles.is_empty():
		return true

	var has_neighbor = false
	var all_match = true

	for i in range(6):
		var neighbor_coord = coord.get_neighbor(i)
		var neighbor_tile = get_tile(neighbor_coord)

		if neighbor_tile != null:
			has_neighbor = true
			# Check if sides match
			var opposite_side = (i + 3) % 6
			if not tile.matches_side(neighbor_tile, i, opposite_side):
				all_match = false
				break

	return has_neighbor and all_match

## Check if placement matches all 6 neighbors (for perfect bonus)
func check_perfect_placement(coord: HexCoord, tile: TileData) -> bool:
	var matched_count = 0

	for i in range(6):
		var neighbor_coord = coord.get_neighbor(i)
		var neighbor_tile = get_tile(neighbor_coord)

		if neighbor_tile != null:
			var opposite_side = (i + 3) % 6
			if tile.matches_side(neighbor_tile, i, opposite_side):
				matched_count += 1
		else:
			# No neighbor on this side, can't be perfect
			return false

	return matched_count == 6

## Get all valid placement positions (positions adjacent to placed tiles)
func get_valid_placement_positions() -> Array[HexCoord]:
	var valid_positions: Array[HexCoord] = []

	if placed_tiles.is_empty():
		# First tile goes at origin
		valid_positions.append(HexCoord.new(0, 0))
		return valid_positions

	var checked: Dictionary = {}

	for hash in placed_tiles.keys():
		var coord_q = hash / 10000
		var coord_r = hash % 10000
		if coord_r > 5000:
			coord_r = coord_r - 10000
		var coord = HexCoord.new(coord_q, coord_r)

		var neighbors = coord.get_all_neighbors()
		for neighbor in neighbors:
			if is_position_empty(neighbor) and not checked.has(neighbor.hash()):
				valid_positions.append(neighbor)
				checked[neighbor.hash()] = true

	return valid_positions

## Calculate connected area size for a terrain type starting from coord
func get_connected_area_size(start_coord: HexCoord, terrain: TerrainType.Type, visited: Dictionary = {}) -> int:
	var coord_hash = start_coord.hash()

	if visited.has(coord_hash):
		return 0

	var tile = get_tile(start_coord)
	if tile == null:
		return 0

	# Check if this tile has the terrain type
	var has_terrain = false
	if tile.center_terrain == terrain:
		has_terrain = true
	else:
		for side_terrain in tile.sides:
			if side_terrain == terrain:
				has_terrain = true
				break

	if not has_terrain:
		return 0

	visited[coord_hash] = true
	var size = 1

	# Check all neighbors
	var neighbors = start_coord.get_all_neighbors()
	for neighbor in neighbors:
		size += get_connected_area_size(neighbor, terrain, visited)

	return size

## Get all tiles of a specific terrain type
func get_tiles_with_terrain(terrain: TerrainType.Type) -> Array[HexCoord]:
	var result: Array[HexCoord] = []

	for hash in placed_tiles.keys():
		var tile = placed_tiles[hash]
		var has_terrain = false

		if tile.center_terrain == terrain:
			has_terrain = true
		else:
			for side_terrain in tile.sides:
				if side_terrain == terrain:
					has_terrain = true
					break

		if has_terrain:
			var coord_q = hash / 10000
			var coord_r = hash % 10000
			if coord_r > 5000:
				coord_r = coord_r - 10000
			result.append(HexCoord.new(coord_q, coord_r))

	return result

## Clear all tiles
func clear_grid() -> void:
	placed_tiles.clear()
	for node in tile_nodes.values():
		if node:
			node.queue_free()
	tile_nodes.clear()
