extends Node
class_name HexGrid

# Hexagonal grid utilities for Opus Magnum-style game
# Uses axial coordinates (q, r)

const SQRT3 = 1.732050807568877

static func axial_to_pixel(q: int, r: int, size: float) -> Vector2:
	var x = size * (SQRT3 * q + SQRT3/2 * r)
	var y = size * (3.0/2 * r)
	return Vector2(x, y)

static func pixel_to_axial(pos: Vector2, size: float) -> Vector2i:
	var q = (SQRT3/3 * pos.x - 1.0/3 * pos.y) / size
	var r = (2.0/3 * pos.y) / size
	return axial_round(Vector2(q, r))

static func axial_round(hex: Vector2) -> Vector2i:
	var q = hex.x
	var r = hex.y
	var s = -q - r

	var rq = round(q)
	var rr = round(r)
	var rs = round(s)

	var q_diff = abs(rq - q)
	var r_diff = abs(rr - r)
	var s_diff = abs(rs - s)

	if q_diff > r_diff and q_diff > s_diff:
		rq = -rr - rs
	elif r_diff > s_diff:
		rr = -rq - rs

	return Vector2i(int(rq), int(rr))

static func get_neighbors(q: int, r: int) -> Array[Vector2i]:
	var directions = [
		Vector2i(1, 0), Vector2i(1, -1), Vector2i(0, -1),
		Vector2i(-1, 0), Vector2i(-1, 1), Vector2i(0, 1)
	]
	var neighbors: Array[Vector2i] = []
	for dir in directions:
		neighbors.append(Vector2i(q + dir.x, r + dir.y))
	return neighbors

static func axial_distance(q1: int, r1: int, q2: int, r2: int) -> int:
	return (abs(q1 - q2) + abs(q1 + r1 - q2 - r2) + abs(r1 - r2)) / 2
