class_name TerrainType
extends RefCounted

## Enum for different terrain types in Dorfromantik
enum Type {
	FIELD,      # Yellow - crops/farmland
	FOREST,     # Green - trees
	VILLAGE,    # Red - houses
	WATER,      # Blue - rivers/lakes
	RAILWAY,    # Gray - train tracks
	NONE        # Empty/undefined
}

## Get color for terrain type (for visual representation)
static func get_color(type: Type) -> Color:
	match type:
		Type.FIELD:
			return Color(0.95, 0.85, 0.3)  # Yellow
		Type.FOREST:
			return Color(0.2, 0.6, 0.2)    # Green
		Type.VILLAGE:
			return Color(0.8, 0.3, 0.3)    # Red
		Type.WATER:
			return Color(0.2, 0.5, 0.8)    # Blue
		Type.RAILWAY:
			return Color(0.5, 0.5, 0.5)    # Gray
		_:
			return Color(0.8, 0.8, 0.8)    # White

## Get terrain type name
static func get_name(type: Type) -> String:
	match type:
		Type.FIELD:
			return "Field"
		Type.FOREST:
			return "Forest"
		Type.VILLAGE:
			return "Village"
		Type.WATER:
			return "Water"
		Type.RAILWAY:
			return "Railway"
		_:
			return "None"
