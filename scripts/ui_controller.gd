extends Control

@onready var game_manager: GameManager = get_node("/root/Main/GameManager")
@onready var workspace: Workspace = get_node("/root/Main/Workspace")

# UI elements
@onready var part_menu: VBoxContainer = $PartMenu
@onready var control_buttons: HBoxContainer = $ControlButtons
@onready var test_button: Button = $ControlButtons/TestButton
@onready var reset_button: Button = $ControlButtons/ResetButton
@onready var goal_label: Label = $GoalLabel
@onready var stats_panel: PanelContainer = $StatsPanel
@onready var stats_label: Label = $StatsPanel/StatsLabel
@onready var review_panel: PanelContainer = $ReviewPanel
@onready var review_label: Label = $ReviewPanel/VBoxContainer/ReviewLabel
@onready var continue_button: Button = $ReviewPanel/VBoxContainer/ContinueButton

func _ready() -> void:
	# Connect signals
	if game_manager:
		game_manager.state_changed.connect(_on_state_changed)
		game_manager.level_completed.connect(_on_level_completed)

	# Connect button signals
	test_button.pressed.connect(_on_test_button_pressed)
	reset_button.pressed.connect(_on_reset_button_pressed)
	continue_button.pressed.connect(_on_continue_button_pressed)

	# Setup part buttons
	setup_part_menu()

	# Initialize UI
	review_panel.visible = false
	update_goal_label()
	update_stats()

func setup_part_menu() -> void:
	var parts = [
		{"name": "Ball", "type": "ball", "cost": 50},
		{"name": "Ramp", "type": "ramp", "cost": 100},
		{"name": "Domino", "type": "domino", "cost": 25},
		{"name": "Lever", "type": "lever", "cost": 150},
	]

	for part_data in parts:
		var button := Button.new()
		button.text = "%s ($%d)" % [part_data.name, part_data.cost]
		button.custom_minimum_size = Vector2(150, 50)
		button.pressed.connect(_on_part_button_pressed.bind(part_data.type))
		part_menu.add_child(button)

func _on_part_button_pressed(part_type: String) -> void:
	if workspace:
		workspace.select_part(part_type)

func _on_test_button_pressed() -> void:
	if game_manager:
		if game_manager.current_state == GameManager.GameState.BRIEFING:
			game_manager.start_building()
		elif game_manager.current_state == GameManager.GameState.BUILD:
			game_manager.change_state(GameManager.GameState.TEST)
		elif game_manager.current_state == GameManager.GameState.TEST:
			game_manager.change_state(GameManager.GameState.BUILD)

func _on_reset_button_pressed() -> void:
	if game_manager:
		game_manager.reset_workspace()

func _on_continue_button_pressed() -> void:
	review_panel.visible = false
	if game_manager:
		game_manager.reset_workspace()

func _on_state_changed(new_state: GameManager.GameState) -> void:
	match new_state:
		GameManager.GameState.BRIEFING:
			# Show "Start Building" button, hide everything else
			test_button.text = "Start Building"
			test_button.visible = true
			reset_button.visible = false
			part_menu.visible = false
			stats_panel.visible = false
			hide_time_controls()
		GameManager.GameState.BUILD:
			test_button.text = "Test Machine"
			test_button.visible = true
			reset_button.visible = true
			part_menu.visible = true
			stats_panel.visible = true
			hide_time_controls()
		GameManager.GameState.TEST:
			test_button.text = "Stop Test"
			part_menu.visible = false
			stats_panel.visible = false
			show_time_controls()
		GameManager.GameState.REVIEW:
			part_menu.visible = false
			hide_time_controls()

# Time control UI elements (created dynamically)
var time_control_panel: HBoxContainer = null
var pause_button: Button = null
var speed_label: Label = null

func show_time_controls() -> void:
	if not time_control_panel:
		create_time_controls()
	time_control_panel.visible = true

func hide_time_controls() -> void:
	if time_control_panel:
		time_control_panel.visible = false

func create_time_controls() -> void:
	# Create time control panel
	time_control_panel = HBoxContainer.new()
	time_control_panel.name = "TimeControlPanel"
	add_child(time_control_panel)

	# Position at bottom center
	time_control_panel.set_anchors_preset(Control.PRESET_BOTTOM_WIDE)
	time_control_panel.position = Vector2(0, -80)
	time_control_panel.custom_minimum_size = Vector2(400, 60)

	# Add panel background
	var panel_style = PanelContainer.new()
	time_control_panel.add_child(panel_style)

	var hbox = HBoxContainer.new()
	panel_style.add_child(hbox)

	# Speed buttons
	var speeds = [
		{"text": "0.25x", "value": 0.25},
		{"text": "0.5x", "value": 0.5},
		{"text": "▶ 1x", "value": 1.0},
		{"text": "2x", "value": 2.0},
		{"text": "4x", "value": 4.0}
	]

	for speed_data in speeds:
		var btn = Button.new()
		btn.text = speed_data.text
		btn.custom_minimum_size = Vector2(70, 50)
		btn.pressed.connect(_on_speed_button_pressed.bind(speed_data.value))
		hbox.add_child(btn)

	# Pause button
	pause_button = Button.new()
	pause_button.text = "|| Pause"
	pause_button.custom_minimum_size = Vector2(90, 50)
	pause_button.pressed.connect(_on_pause_button_pressed)
	hbox.add_child(pause_button)

	# Speed label
	speed_label = Label.new()
	speed_label.text = "Speed: 1.0x"
	speed_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	speed_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	hbox.add_child(speed_label)

	time_control_panel.visible = false

func _on_speed_button_pressed(speed: float) -> void:
	Engine.time_scale = speed
	if speed_label:
		speed_label.text = "Speed: %.2fx" % speed
	# Unpause if paused
	get_tree().paused = false
	if pause_button:
		pause_button.text = "|| Pause"

func _on_pause_button_pressed() -> void:
	get_tree().paused = not get_tree().paused
	if pause_button:
		if get_tree().paused:
			pause_button.text = "▶ Resume"
		else:
			pause_button.text = "|| Pause"

func _on_level_completed(cost: int, time: float, size: int) -> void:
	show_review(cost, time, size)

func show_review(cost: int, time: float, size: int) -> void:
	var cost_stars = game_manager.get_cost_stars()
	var time_stars = game_manager.get_time_stars()
	var size_stars = game_manager.get_size_stars()

	var review_text = "Level Complete!\n\n"
	review_text += "Cost: $%d %s\n" % [cost, get_stars_text(cost_stars)]
	review_text += "Time: %.2fs %s\n" % [time, get_stars_text(time_stars)]
	review_text += "Parts: %d %s\n" % [size, get_stars_text(size_stars)]
	review_text += "\nTotal Stars: %d/9" % (cost_stars + time_stars + size_stars)

	review_label.text = review_text
	review_panel.visible = true

func get_stars_text(count: int) -> String:
	var stars = ""
	for i in range(3):
		if i < count:
			stars += "★"
		else:
			stars += "☆"
	return stars

func update_goal_label() -> void:
	if game_manager and game_manager.current_level:
		goal_label.text = game_manager.current_level.get("name", "")

func update_stats() -> void:
	if game_manager:
		var budget = game_manager.current_level.get("budget", 1000)
		var cost = game_manager.total_cost
		var parts = game_manager.placed_parts.size()
		stats_label.text = "Budget: $%d / $%d\nParts: %d" % [cost, budget, parts]

func _process(_delta: float) -> void:
	update_stats()
