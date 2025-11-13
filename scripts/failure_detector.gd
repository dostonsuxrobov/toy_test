extends Node
class_name FailureDetector

@onready var game_manager: GameManager = get_node("/root/Main/GameManager")

# Failure detection settings
@export var fall_off_y: float = -10.0  # Y position below which parts are considered "fallen off"
@export var max_simulation_time: float = 60.0  # Max time before auto-fail (seconds)

# Tracking
var simulation_start_time: float = 0.0
var failed_parts: Array[Node3D] = []

signal failure_detected(part: Node3D, reason: String)

func _ready() -> void:
	if game_manager:
		game_manager.state_changed.connect(_on_state_changed)

func _on_state_changed(new_state: GameManager.GameState) -> void:
	if new_state == GameManager.GameState.TEST:
		start_monitoring()
	else:
		stop_monitoring()

func start_monitoring() -> void:
	simulation_start_time = Time.get_ticks_msec() / 1000.0
	failed_parts.clear()
	set_process(true)

func stop_monitoring() -> void:
	set_process(false)
	failed_parts.clear()

func _process(_delta: float) -> void:
	if game_manager.current_state != GameManager.GameState.TEST:
		return

	# Check for parts that have fallen off
	for part in game_manager.placed_parts:
		if not is_instance_valid(part):
			continue

		# Skip if already marked as failed
		if part in failed_parts:
			continue

		# Check if part fell off the map
		if part.global_position.y < fall_off_y:
			on_part_failed(part, "fell off the map")

	# Check for timeout
	var elapsed_time = (Time.get_ticks_msec() / 1000.0) - simulation_start_time
	if elapsed_time > max_simulation_time:
		on_timeout_failure()

func on_part_failed(part: Node3D, reason: String) -> void:
	if part in failed_parts:
		return

	failed_parts.append(part)
	print("FAILURE: Part ", part.name, " ", reason)

	# Highlight the failed part
	highlight_failed_part(part)

	# Pause the simulation
	get_tree().paused = true

	# Emit signal
	failure_detected.emit(part, reason)

	# Show failure message
	show_failure_message(part, reason)

func on_timeout_failure() -> void:
	print("FAILURE: Simulation timed out after ", max_simulation_time, " seconds")
	get_tree().paused = true
	show_failure_message(null, "simulation took too long")

func highlight_failed_part(part: Node3D) -> void:
	# Change the part's color to bright red
	for child in part.get_children():
		if child is MeshInstance3D:
			var mat = child.get_active_material(0)
			if mat:
				mat = mat.duplicate()
				mat.albedo_color = Color(1.0, 0.0, 0.0)  # Bright red
				mat.emission_enabled = true
				mat.emission = Color(1.0, 0.2, 0.2)
				mat.emission_energy_multiplier = 2.0
				child.set_surface_override_material(0, mat)

func show_failure_message(part: Node3D, reason: String) -> void:
	# Create a temporary label to show the failure
	var label = Label.new()
	label.name = "FailureMessage"

	if part:
		label.text = "FAILURE!\n%s %s\n\nPress STOP to reset" % [part.name, reason]
	else:
		label.text = "FAILURE!\n%s\n\nPress STOP to reset" % reason

	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER

	# Style the label
	label.add_theme_color_override("font_color", Color(1.0, 0.2, 0.2))
	label.add_theme_font_size_override("font_size", 32)

	# Position at center of screen
	label.set_anchors_preset(Control.PRESET_CENTER)
	label.position = Vector2(-200, -100)
	label.size = Vector2(400, 200)

	# Add to UI
	var ui = get_node("/root/Main/UI")
	if ui:
		ui.add_child(label)

		# Remove after state change
		game_manager.state_changed.connect(func(_state):
			if is_instance_valid(label):
				label.queue_free()
		)
