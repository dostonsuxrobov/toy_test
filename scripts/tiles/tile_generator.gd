class_name TileGenerator
extends RefCounted

## Generates random tiles following Dorfromantik-style patterns
## Tiles typically have 1-3 different terrain types

var rng: RandomNumberGenerator

func _init() -> void:
	rng = RandomNumberGenerator.new()
	rng.randomize()

## Generate a random tile
func generate_tile() -> TileData:
	var pattern_type = rng.randi_range(0, 10)

	if pattern_type < 3:
		# Single terrain (30%)
		return generate_single_terrain()
	elif pattern_type < 7:
		# Two terrain split (40%)
		return generate_two_terrain_split()
	elif pattern_type < 9:
		# Three terrain tile (20%)
		return generate_three_terrain()
	else:
		# Complex pattern (10%)
		return generate_complex_pattern()

## Generate a tile with single terrain type
func generate_single_terrain() -> TileData:
	var terrain = get_random_terrain()
	var sides = [terrain, terrain, terrain, terrain, terrain, terrain]
	return TileData.new(sides, terrain)

## Generate a tile split between two terrains
func generate_two_terrain_split() -> TileData:
	var terrain1 = get_random_terrain()
	var terrain2 = get_random_terrain_different(terrain1)

	# Random split pattern (2-4, 3-3, 1-5, etc.)
	var split = rng.randi_range(1, 4)
	var sides = []

	for i in range(6):
		if i < split:
			sides.append(terrain1)
		else:
			sides.append(terrain2)

	# Randomly shuffle to create variation
	if rng.randf() > 0.5:
		sides.reverse()

	var center = terrain1 if rng.randf() > 0.5 else terrain2
	return TileData.new(sides, center)

## Generate a tile with three different terrains
func generate_three_terrain() -> TileData:
	var terrain1 = get_random_terrain()
	var terrain2 = get_random_terrain_different(terrain1)
	var terrain3 = get_random_terrain_different_from([terrain1, terrain2])

	var sides = []
	var split1 = rng.randi_range(1, 3)
	var split2 = rng.randi_range(split1 + 1, 5)

	for i in range(6):
		if i < split1:
			sides.append(terrain1)
		elif i < split2:
			sides.append(terrain2)
		else:
			sides.append(terrain3)

	var terrains = [terrain1, terrain2, terrain3]
	var center = terrains[rng.randi_range(0, 2)]
	return TileData.new(sides, center)

## Generate a complex pattern with alternating or mixed terrains
func generate_complex_pattern() -> TileData:
	var terrain1 = get_random_terrain()
	var terrain2 = get_random_terrain_different(terrain1)

	var sides = []
	var pattern = rng.randi_range(0, 2)

	if pattern == 0:
		# Alternating pattern
		for i in range(6):
			sides.append(terrain1 if i % 2 == 0 else terrain2)
	elif pattern == 1:
		# Two sides each, alternating
		for i in range(6):
			sides.append(terrain1 if (i / 2) % 2 == 0 else terrain2)
	else:
		# Random mix
		for i in range(6):
			sides.append(terrain1 if rng.randf() > 0.5 else terrain2)

	var center = terrain1 if rng.randf() > 0.5 else terrain2
	return TileData.new(sides, center)

## Get a random terrain type
func get_random_terrain() -> TerrainType.Type:
	var terrains = [
		TerrainType.Type.FIELD,
		TerrainType.Type.FOREST,
		TerrainType.Type.VILLAGE,
		TerrainType.Type.WATER,
		TerrainType.Type.RAILWAY
	]
	return terrains[rng.randi_range(0, terrains.size() - 1)]

## Get a random terrain different from the given one
func get_random_terrain_different(exclude: TerrainType.Type) -> TerrainType.Type:
	var terrain = get_random_terrain()
	while terrain == exclude:
		terrain = get_random_terrain()
	return terrain

## Get a random terrain different from all in the exclude list
func get_random_terrain_different_from(exclude: Array) -> TerrainType.Type:
	var terrain = get_random_terrain()
	while terrain in exclude:
		terrain = get_random_terrain()
	return terrain

## Generate a tile with a quest
func generate_quest_tile(quest_terrain: TerrainType.Type, quest_count: int) -> TileData:
	var tile = generate_tile()

	# Ensure the tile has some of the quest terrain
	var has_terrain = false
	for side in tile.sides:
		if side == quest_terrain:
			has_terrain = true
			break

	# If not, modify one tile to have it
	if not has_terrain:
		var side_to_modify = rng.randi_range(0, 5)
		tile.sides[side_to_modify] = quest_terrain

	tile.has_quest = true
	tile.quest_type = quest_terrain
	tile.quest_target = quest_count

	return tile
