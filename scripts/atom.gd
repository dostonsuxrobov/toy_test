extends Node2D
class_name Atom

# Represents an atom/molecule in the game

enum AtomType {
	SALT,    # Red
	WATER,   # Blue
	FIRE,    # Orange
	EARTH    # Green
}

@export var atom_type: AtomType = AtomType.SALT
var grid_pos: Vector2i = Vector2i(0, 0)
var held_by_arm: MechanicalArm = null

const COLORS = {
	AtomType.SALT: Color(0.9, 0.2, 0.2),
	AtomType.WATER: Color(0.2, 0.5, 0.9),
	AtomType.FIRE: Color(0.9, 0.5, 0.1),
	AtomType.EARTH: Color(0.3, 0.7, 0.3)
}

func _ready():
	z_index = 10
	queue_redraw()

func _draw():
	var color = COLORS.get(atom_type, Color.WHITE)

	# Glow effect
	draw_circle(Vector2.ZERO, 18, Color(color.r, color.g, color.b, 0.3))

	# Main circle
	draw_circle(Vector2.ZERO, 15, color)

	# Outline
	draw_arc(Vector2.ZERO, 15, 0, TAU, 32, Color.WHITE, 2.5)

	# Small highlight
	draw_circle(Vector2(-5, -5), 4, Color(1, 1, 1, 0.6))

func set_grid_position(q: int, r: int, hex_size: float):
	grid_pos = Vector2i(q, r)
	position = HexGrid.axial_to_pixel(q, r, hex_size)

func get_atom_type_name() -> String:
	match atom_type:
		AtomType.SALT: return "Salt"
		AtomType.WATER: return "Water"
		AtomType.FIRE: return "Fire"
		AtomType.EARTH: return "Earth"
	return "Unknown"
