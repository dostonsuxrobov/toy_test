extends Node2D
class_name GameManager

# Main game manager for Opus Magnum-style puzzle game

const HEX_SIZE = 40.0
const TICK_SPEED = 0.5  # Seconds per simulation step

@export var grid_width: int = 10
@export var grid_height: int = 8

var arms: Array[MechanicalArm] = []
var atoms: Array[Atom] = []
var input_zones: Array[Dictionary] = []
var output_zones: Array[Dictionary] = []

var is_playing: bool = false
var tick_timer: float = 0.0
var cycle_count: int = 0

var camera: CameraController
var ui_layer: CanvasLayer

# Placement mode
var placement_mode: String = ""  # "arm", "input", "output"
var selected_atom_type: Atom.AtomType = Atom.AtomType.SALT

# Mouse hover
var hovered_hex: Vector2i = Vector2i(0, 0)

signal cycle_completed
signal level_completed

func _ready():
	setup_camera()
	setup_level()

func _process(delta):
	if not is_playing:
		# Update hovered hex for visual feedback
		var mouse_pos = get_viewport_mouse_world_position()
		hovered_hex = HexGrid.pixel_to_axial(mouse_pos, HEX_SIZE)
		queue_redraw()

	if is_playing:
		tick_timer += delta
		if tick_timer >= TICK_SPEED:
			tick_timer = 0.0
			execute_simulation_step()

func get_viewport_mouse_world_position() -> Vector2:
	# Convert viewport mouse position to world position accounting for camera
	if camera:
		var viewport_pos = get_viewport().get_mouse_position()
		var viewport_size = get_viewport().get_visible_rect().size
		var viewport_center = viewport_size / 2.0
		# Calculate world position: camera position + (mouse offset from center) / zoom
		var world_pos = camera.position + (viewport_pos - viewport_center) / camera.zoom
		return world_pos
	return get_global_mouse_position()

func _draw():
	# Draw hex grid
	for q in range(-grid_width, grid_width):
		for r in range(-grid_height, grid_height):
			var pos = HexGrid.axial_to_pixel(q, r, HEX_SIZE)
			draw_hexagon(pos, HEX_SIZE, Color(0.2, 0.2, 0.25, 0.3))

	# Draw hovered hex
	if placement_mode == "arm":
		var hover_pos = HexGrid.axial_to_pixel(hovered_hex.x, hovered_hex.y, HEX_SIZE)
		draw_hexagon(hover_pos, HEX_SIZE, Color(0.8, 0.8, 0.2, 0.6))

	# Draw input zones
	for zone in input_zones:
		var pos = HexGrid.axial_to_pixel(zone.pos.x, zone.pos.y, HEX_SIZE)
		draw_hexagon(pos, HEX_SIZE, Color(0.2, 0.6, 0.3, 0.5))

	# Draw output zones
	for zone in output_zones:
		var pos = HexGrid.axial_to_pixel(zone.pos.x, zone.pos.y, HEX_SIZE)
		draw_hexagon(pos, HEX_SIZE, Color(0.6, 0.2, 0.3, 0.5))

func draw_hexagon(center: Vector2, size: float, color: Color):
	var points = PackedVector2Array()
	for i in range(7):
		var angle = TAU / 6 * i - PI / 6
		points.append(center + Vector2(cos(angle), sin(angle)) * size)
	draw_polyline(points, color, 1.5)

func setup_camera():
	camera = CameraController.new()
	add_child(camera)

func setup_level():
	# Simple level: Move 3 salt atoms from input to output
	input_zones.append({
		"pos": Vector2i(-5, 0),
		"atom_type": Atom.AtomType.SALT,
		"spawn_count": 3,
		"spawned": 0
	})

	output_zones.append({
		"pos": Vector2i(5, 0),
		"required_type": Atom.AtomType.SALT,
		"required_count": 3,
		"collected": 0
	})

	# Spawn initial atoms
	spawn_initial_atoms()
	queue_redraw()

func spawn_initial_atoms():
	for zone in input_zones:
		while zone.spawned < zone.spawn_count:
			var atom = Atom.new()
			atom.atom_type = zone.atom_type
			# Stack atoms vertically if multiple
			var offset = zone.spawned
			atom.set_grid_position(zone.pos.x, zone.pos.y + offset, HEX_SIZE)
			atoms.append(atom)
			add_child(atom)
			zone.spawned += 1

func execute_simulation_step():
	# Execute all arm instructions
	for arm in arms:
		arm.execute_next_instruction(atoms)

	# Check output zones
	check_outputs()

	# Check win condition
	check_win_condition()

	cycle_count += 1
	cycle_completed.emit()

func check_outputs():
	for i in range(atoms.size() - 1, -1, -1):
		var atom = atoms[i]
		if atom.held_by_arm:
			continue

		for zone in output_zones:
			if atom.grid_pos == zone.pos and atom.atom_type == zone.required_type:
				zone.collected += 1
				atoms.remove_at(i)
				atom.queue_free()
				break

func check_win_condition():
	for zone in output_zones:
		if zone.collected < zone.required_count:
			return

	# All outputs satisfied!
	is_playing = false
	level_completed.emit()
	print("Level completed in ", cycle_count, " cycles!")

func play():
	is_playing = true

func pause():
	is_playing = false

func reset():
	is_playing = false
	cycle_count = 0
	tick_timer = 0.0

	# Remove all atoms
	for atom in atoms:
		atom.queue_free()
	atoms.clear()

	# Reset arms
	for arm in arms:
		arm.reset()

	# Reset zones
	for zone in input_zones:
		zone.spawned = 0
	for zone in output_zones:
		zone.collected = 0

	# Respawn initial atoms
	spawn_initial_atoms()
	queue_redraw()

func add_arm_at_position(q: int, r: int):
	var arm = MechanicalArm.new()
	arm.set_grid_position(q, r, HEX_SIZE)
	# Default program: grab, rotate CW 3 times, drop, rotate CW 3 times (loop)
	arm.add_instruction(MechanicalArm.Instruction.GRAB)
	arm.add_instruction(MechanicalArm.Instruction.ROTATE_CW)
	arm.add_instruction(MechanicalArm.Instruction.ROTATE_CW)
	arm.add_instruction(MechanicalArm.Instruction.ROTATE_CW)
	arm.add_instruction(MechanicalArm.Instruction.DROP)
	arm.add_instruction(MechanicalArm.Instruction.ROTATE_CW)
	arm.add_instruction(MechanicalArm.Instruction.ROTATE_CW)
	arm.add_instruction(MechanicalArm.Instruction.ROTATE_CW)
	arms.append(arm)
	add_child(arm)
	print("Arm placed! Total arms: ", arms.size())

func _unhandled_input(event):
	# Use _unhandled_input so camera can handle its inputs first
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		print("Left click detected! Placement mode: ", placement_mode)
		if placement_mode == "arm":
			var mouse_pos = get_viewport_mouse_world_position()
			var hex_pos = HexGrid.pixel_to_axial(mouse_pos, HEX_SIZE)
			print("Placing arm at hex: ", hex_pos, " (world pos: ", mouse_pos, ")")
			add_arm_at_position(hex_pos.x, hex_pos.y)
			get_viewport().set_input_as_handled()
