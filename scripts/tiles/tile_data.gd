class_name TileData
extends RefCounted

## Represents a hexagonal tile with terrain on each of its 6 sides and a center
## Sides are numbered 0-5 starting from East and going counter-clockwise

var sides: Array[TerrainType.Type] = []  # 6 terrain types, one for each side
var center_terrain: TerrainType.Type = TerrainType.Type.NONE
var rotation: int = 0  # Current rotation (0-5), in 60-degree increments
var has_quest: bool = false
var quest_type: TerrainType.Type = TerrainType.Type.NONE
var quest_target: int = 0
var is_perfect: bool = false  # Set to true if all 6 sides match neighbors when placed

func _init(side_terrains: Array, center: TerrainType.Type) -> void:
	center_terrain = center

	# Initialize with 6 sides
	sides.resize(6)
	for i in range(6):
		if i < side_terrains.size():
			sides[i] = side_terrains[i]
		else:
			sides[i] = center

	# Ensure we have exactly 6 sides
	if sides.size() < 6:
		sides.resize(6)
		for i in range(sides.size()):
			if sides[i] == null:
				sides[i] = center

## Get terrain type for a specific side (accounting for rotation)
func get_side_terrain(side: int) -> TerrainType.Type:
	var rotated_side = (side - rotation + 6) % 6
	return sides[rotated_side]

## Rotate tile clockwise (increment rotation)
func rotate_clockwise() -> void:
	rotation = (rotation + 1) % 6

## Rotate tile counter-clockwise (decrement rotation)
func rotate_counter_clockwise() -> void:
	rotation = (rotation - 1 + 6) % 6

## Set rotation directly
func set_rotation(new_rotation: int) -> void:
	rotation = new_rotation % 6

## Check if this tile matches another tile on a specific side
func matches_side(other: TileData, this_side: int, other_side: int) -> bool:
	return get_side_terrain(this_side) == other.get_side_terrain(other_side)

## Create a copy of this tile
func duplicate() -> TileData:
	var new_tile = TileData.new(sides.duplicate(), center_terrain)
	new_tile.rotation = rotation
	new_tile.has_quest = has_quest
	new_tile.quest_type = quest_type
	new_tile.quest_target = quest_target
	new_tile.is_perfect = is_perfect
	return new_tile

## Get all unique terrains on this tile
func get_unique_terrains() -> Array[TerrainType.Type]:
	var unique: Array[TerrainType.Type] = []
	for terrain in sides:
		if terrain not in unique:
			unique.append(terrain)
	return unique

## String representation for debugging
func _to_string() -> String:
	var side_names = []
	for i in range(6):
		side_names.append(TerrainType.get_name(get_side_terrain(i)))
	return "Tile[%s] (center: %s, rot: %d)" % [", ".join(side_names), TerrainType.get_name(center_terrain), rotation]
