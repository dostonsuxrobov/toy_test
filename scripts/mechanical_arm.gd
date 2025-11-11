extends Node2D
class_name MechanicalArm

# Mechanical arm that can grab, rotate, and drop atoms

signal instruction_executed

var grid_pos: Vector2i = Vector2i(0, 0)
var arm_length: int = 2
var rotation_angle: int = 0  # In 60-degree increments (0-5)
var held_atom: Atom = null
var instructions: Array = []
var current_instruction_index: int = 0
var hex_size: float = 40.0

enum Instruction {
	GRAB,
	DROP,
	ROTATE_CW,   # Clockwise
	ROTATE_CCW,  # Counter-clockwise
	EXTEND,
	RETRACT,
	WAIT
}

func _ready():
	z_index = 5
	queue_redraw()

func _draw():
	var arm_end = get_arm_end_local()

	# Draw arm shadow
	draw_line(Vector2(2, 2), arm_end + Vector2(2, 2), Color(0, 0, 0, 0.3), 8.0)

	# Draw arm
	draw_line(Vector2.ZERO, arm_end, Color(0.5, 0.5, 0.5), 6.0)
	draw_line(Vector2.ZERO, arm_end, Color(0.7, 0.7, 0.7), 4.0)

	# Draw base
	draw_circle(Vector2.ZERO, 14, Color(0.3, 0.3, 0.3))
	draw_circle(Vector2.ZERO, 12, Color(0.5, 0.5, 0.5))
	draw_arc(Vector2.ZERO, 12, 0, TAU, 32, Color(0.8, 0.8, 0.8), 2.5)

	# Draw direction indicator
	var dir_end = Vector2(cos(rotation_angle * PI / 3.0), sin(rotation_angle * PI / 3.0)) * 8
	draw_line(Vector2.ZERO, dir_end, Color(1, 1, 0.2), 2.0)

	# Draw gripper
	draw_circle(arm_end, 10, Color(0.2, 0.2, 0.2))
	draw_circle(arm_end, 8, Color(0.4, 0.4, 0.4))

	# Draw gripper state
	if held_atom:
		draw_arc(arm_end, 12, 0, TAU, 32, Color(0.2, 1.0, 0.2), 3.0)
	else:
		draw_arc(arm_end, 10, 0, TAU, 32, Color(0.8, 0.8, 0.8), 2.0)

func set_grid_position(q: int, r: int, size: float):
	grid_pos = Vector2i(q, r)
	hex_size = size
	position = HexGrid.axial_to_pixel(q, r, hex_size)

func get_arm_end_local() -> Vector2:
	var angle_rad = rotation_angle * PI / 3.0
	var length = arm_length * hex_size
	return Vector2(cos(angle_rad), sin(angle_rad)) * length

func get_arm_end_grid() -> Vector2i:
	var directions = [
		Vector2i(1, 0), Vector2i(0, 1), Vector2i(-1, 1),
		Vector2i(-1, 0), Vector2i(0, -1), Vector2i(1, -1)
	]
	var dir = directions[rotation_angle % 6]
	return Vector2i(grid_pos.x + dir.x * arm_length, grid_pos.y + dir.y * arm_length)

func execute_next_instruction(atoms: Array) -> bool:
	if current_instruction_index >= instructions.size():
		current_instruction_index = 0
		return false

	var instr = instructions[current_instruction_index]
	execute_instruction(instr, atoms)
	current_instruction_index += 1
	instruction_executed.emit()
	queue_redraw()
	return true

func execute_instruction(instr: Instruction, atoms: Array):
	match instr:
		Instruction.GRAB:
			grab_atom(atoms)
		Instruction.DROP:
			drop_atom()
		Instruction.ROTATE_CW:
			rotation_angle = (rotation_angle + 1) % 6
		Instruction.ROTATE_CCW:
			rotation_angle = (rotation_angle - 1 + 6) % 6
		Instruction.EXTEND:
			arm_length = min(arm_length + 1, 3)
		Instruction.RETRACT:
			arm_length = max(arm_length - 1, 1)
		Instruction.WAIT:
			pass

	# Update held atom position
	if held_atom:
		var end_pos = get_arm_end_grid()
		held_atom.set_grid_position(end_pos.x, end_pos.y, hex_size)

func grab_atom(atoms: Array):
	if held_atom:
		return

	var end_pos = get_arm_end_grid()
	for atom in atoms:
		if atom is Atom and atom.grid_pos == end_pos and not atom.held_by_arm:
			held_atom = atom
			atom.held_by_arm = self
			break

func drop_atom():
	if held_atom:
		held_atom.held_by_arm = null
		held_atom = null

func reset():
	current_instruction_index = 0
	if held_atom:
		drop_atom()
	queue_redraw()

func add_instruction(instr: Instruction):
	instructions.append(instr)

func clear_instructions():
	instructions.clear()
	current_instruction_index = 0
