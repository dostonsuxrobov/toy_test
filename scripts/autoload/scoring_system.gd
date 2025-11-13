extends Node

## Manages scoring and quest completion

signal score_changed(new_score: int, points_gained: int)
signal quest_completed(quest_type: TerrainType.Type, area_size: int, bonus_points: int)

var total_score: int = 0
var active_quests: Array[Dictionary] = []  # [{type: TerrainType, target: int, reward: int}]

const PERFECT_PLACEMENT_BONUS = 50
const QUEST_COMPLETION_MULTIPLIER = 10

func _ready() -> void:
	pass

## Calculate score for a tile placement
func calculate_placement_score(hex_grid: HexGrid, coord: HexCoord, tile: TileData) -> int:
	var points = 0

	# Base points for placement
	points += 1

	# Check connected areas for each terrain type on the tile
	var terrains = tile.get_unique_terrains()
	for terrain in terrains:
		var area_size = hex_grid.get_connected_area_size(coord, terrain)

		# Points based on area size (larger areas = more points)
		if area_size >= 10:
			points += area_size * 2
		elif area_size >= 5:
			points += area_size
		else:
			points += area_size / 2

	# Perfect placement bonus (all 6 sides match neighbors)
	if tile.is_perfect:
		points += PERFECT_PLACEMENT_BONUS

	# Check quest completion
	if tile.has_quest:
		var quest_area_size = hex_grid.get_connected_area_size(coord, tile.quest_type)
		if quest_area_size >= tile.quest_target:
			var quest_bonus = tile.quest_target * QUEST_COMPLETION_MULTIPLIER
			points += quest_bonus
			quest_completed.emit(tile.quest_type, quest_area_size, quest_bonus)

	return points

## Add points to total score
func add_score(points: int) -> void:
	if points > 0:
		total_score += points
		score_changed.emit(total_score, points)

## Reset score
func reset_score() -> void:
	total_score = 0
	active_quests.clear()
	score_changed.emit(total_score, 0)

## Add a new quest
func add_quest(terrain: TerrainType.Type, target: int) -> void:
	var quest = {
		"type": terrain,
		"target": target,
		"reward": target * QUEST_COMPLETION_MULTIPLIER
	}
	active_quests.append(quest)

## Check if a quest is completed
func check_quest_completion(hex_grid: HexGrid, terrain: TerrainType.Type) -> bool:
	for quest in active_quests:
		if quest.type == terrain:
			# Find largest connected area of this terrain
			var tiles = hex_grid.get_tiles_with_terrain(terrain)
			var max_area = 0
			var visited = {}

			for tile_coord in tiles:
				if not visited.has(tile_coord.hash()):
					var area_size = hex_grid.get_connected_area_size(tile_coord, terrain, visited)
					max_area = max(max_area, area_size)

			if max_area >= quest.target:
				return true

	return false

## Get active quests
func get_active_quests() -> Array[Dictionary]:
	return active_quests

## Get score
func get_score() -> int:
	return total_score
