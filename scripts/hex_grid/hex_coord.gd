class_name HexCoord
extends RefCounted

## Represents a hexagonal coordinate using axial coordinates (q, r)
## This is the standard coordinate system for hexagonal grids

var q: int  # Column
var r: int  # Row

func _init(q_val: int = 0, r_val: int = 0) -> void:
	q = q_val
	r = r_val

## Get the s coordinate (cube coordinate system: q + r + s = 0)
func s() -> int:
	return -q - r

## Convert hex coordinate to world position (flat-top hexagons)
func to_world_position(hex_size: float = 1.0) -> Vector3:
	var x = hex_size * (3.0/2.0 * q)
	var z = hex_size * (sqrt(3.0)/2.0 * q + sqrt(3.0) * r)
	return Vector3(x, 0, z)

## Get neighbor coordinate in direction (0-5)
func get_neighbor(direction: int) -> HexCoord:
	var directions = [
		Vector2i(1, 0),   # E
		Vector2i(1, -1),  # NE
		Vector2i(0, -1),  # NW
		Vector2i(-1, 0),  # W
		Vector2i(-1, 1),  # SW
		Vector2i(0, 1)    # SE
	]
	var dir = directions[direction % 6]
	return HexCoord.new(q + dir.x, r + dir.y)

## Get all 6 neighbor coordinates
func get_all_neighbors() -> Array[HexCoord]:
	var neighbors: Array[HexCoord] = []
	for i in range(6):
		neighbors.append(get_neighbor(i))
	return neighbors

## Distance between two hex coordinates
func distance_to(other: HexCoord) -> int:
	return (abs(q - other.q) + abs(r - other.r) + abs(s() - other.s())) / 2

## Check equality
func equals(other: HexCoord) -> bool:
	return q == other.q and r == other.r

## Hash function for use in dictionaries
func hash() -> int:
	return q * 10000 + r

## String representation
func _to_string() -> String:
	return "HexCoord(%d, %d)" % [q, r]

## Static method to convert world position to hex coordinate
static func from_world_position(world_pos: Vector3, hex_size: float = 1.0) -> HexCoord:
	var q_float = (2.0/3.0 * world_pos.x) / hex_size
	var r_float = (-1.0/3.0 * world_pos.x + sqrt(3.0)/3.0 * world_pos.z) / hex_size
	return hex_round(q_float, r_float)

## Round fractional hex coordinates to nearest hex
static func hex_round(q_float: float, r_float: float) -> HexCoord:
	var s_float = -q_float - r_float

	var q_int = round(q_float)
	var r_int = round(r_float)
	var s_int = round(s_float)

	var q_diff = abs(q_int - q_float)
	var r_diff = abs(r_int - r_float)
	var s_diff = abs(s_int - s_float)

	if q_diff > r_diff and q_diff > s_diff:
		q_int = -r_int - s_int
	elif r_diff > s_diff:
		r_int = -q_int - s_int

	return HexCoord.new(int(q_int), int(r_int))
