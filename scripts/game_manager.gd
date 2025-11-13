extends Node
class_name GameManager

# Game states
enum GameState { BRIEFING, BUILD, TEST, REVIEW }
var current_state: GameState = GameState.BUILD  # Start in BUILD mode

# Current level/contract data
var current_level: Dictionary = {}
var placed_parts: Array[Node3D] = []
var total_cost: int = 0
var start_time: float = 0.0
var completion_time: float = 0.0

# Signals
signal state_changed(new_state: GameState)
signal level_completed(cost: int, time: float, size: int)
signal goal_achieved()

func _ready() -> void:
	# Load first level
	load_level({
		"name": "Press the Button",
		"description": "Build a machine that presses the red button",
		"budget": 1000,
		"target_time": 10.0
	})

func load_level(level_data: Dictionary) -> void:
	current_level = level_data
	reset_workspace()

func reset_workspace() -> void:
	# Clear all placed parts
	for part in placed_parts:
		if is_instance_valid(part):
			part.queue_free()
	placed_parts.clear()
	total_cost = 0
	completion_time = 0.0
	change_state(GameState.BUILD)  # Start in BUILD mode

func start_building() -> void:
	# Transition from BRIEFING to BUILD mode
	change_state(GameState.BUILD)

func change_state(new_state: GameState) -> void:
	if current_state == new_state:
		return

	current_state = new_state
	state_changed.emit(new_state)

	match new_state:
		GameState.BRIEFING:
			# Lock camera and building - establishing shot
			enable_physics(false)
			reset_time_scale()
		GameState.BUILD:
			# Enable building mode
			enable_physics(false)
			reset_time_scale()
		GameState.TEST:
			# Start physics simulation
			enable_physics(true)
			reset_time_scale()
			start_time = Time.get_ticks_msec() / 1000.0
		GameState.REVIEW:
			# Calculate completion time
			completion_time = (Time.get_ticks_msec() / 1000.0) - start_time
			show_review()
			reset_time_scale()

func reset_time_scale() -> void:
	Engine.time_scale = 1.0
	get_tree().paused = false

func enable_physics(enabled: bool) -> void:
	# Toggle physics on all placed parts
	for part in placed_parts:
		if is_instance_valid(part) and part is RigidBody3D:
			if enabled:
				part.freeze = false
			else:
				part.freeze = true

func add_part(part: Node3D, cost: int) -> void:
	placed_parts.append(part)
	total_cost += cost

func remove_part(part: Node3D, cost: int) -> void:
	placed_parts.erase(part)
	total_cost -= cost
	if is_instance_valid(part):
		part.queue_free()

func on_goal_achieved() -> void:
	if current_state == GameState.TEST:
		goal_achieved.emit()
		# Wait a moment before showing review
		await get_tree().create_timer(2.0).timeout
		change_state(GameState.REVIEW)

func show_review() -> void:
	var size = placed_parts.size()
	level_completed.emit(total_cost, completion_time, size)
	print("Level Complete!")
	print("Cost: $%d / $%d" % [total_cost, current_level.get("budget", 1000)])
	print("Time: %.2fs / %.2fs" % [completion_time, current_level.get("target_time", 10.0)])
	print("Parts Used: %d" % size)

func get_cost_stars() -> int:
	var budget = current_level.get("budget", 1000)
	if total_cost <= budget * 0.5:
		return 3
	elif total_cost <= budget * 0.75:
		return 2
	elif total_cost <= budget:
		return 1
	return 0

func get_time_stars() -> int:
	var target = current_level.get("target_time", 10.0)
	if completion_time <= target * 0.5:
		return 3
	elif completion_time <= target * 0.75:
		return 2
	elif completion_time <= target:
		return 1
	return 0

func get_size_stars() -> int:
	var part_count = placed_parts.size()
	if part_count <= 5:
		return 3
	elif part_count <= 10:
		return 2
	elif part_count <= 15:
		return 1
	return 0
