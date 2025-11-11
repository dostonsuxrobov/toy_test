extends CanvasLayer
class_name UIController

# UI Controller for game controls

var game_manager: GameManager

@onready var play_button: Button
@onready var pause_button: Button
@onready var reset_button: Button
@onready var place_arm_button: Button
@onready var cycle_label: Label
@onready var info_label: Label

func _ready():
	setup_ui()

func setup_ui():
	# Control panel
	var panel = PanelContainer.new()
	panel.position = Vector2(10, 10)
	panel.custom_minimum_size = Vector2(250, 0)
	add_child(panel)

	var vbox = VBoxContainer.new()
	vbox.add_theme_constant_override("separation", 5)
	panel.add_child(vbox)

	# Title
	var title = Label.new()
	title.text = "Opus Mechanicus"
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.add_theme_font_size_override("font_size", 20)
	vbox.add_child(title)

	# Separator
	var separator1 = HSeparator.new()
	vbox.add_child(separator1)

	# Cycle counter
	cycle_label = Label.new()
	cycle_label.text = "Cycles: 0"
	vbox.add_child(cycle_label)

	# Info label
	info_label = Label.new()
	info_label.text = "Click to place arm"
	info_label.autowrap_mode = TextServer.AUTOWRAP_WORD
	info_label.custom_minimum_size = Vector2(230, 0)
	vbox.add_child(info_label)

	var separator2 = HSeparator.new()
	vbox.add_child(separator2)

	# Control buttons
	var button_box = HBoxContainer.new()
	button_box.add_theme_constant_override("separation", 5)
	vbox.add_child(button_box)

	play_button = Button.new()
	play_button.text = "Play"
	play_button.custom_minimum_size = Vector2(70, 0)
	play_button.pressed.connect(_on_play_pressed)
	button_box.add_child(play_button)

	pause_button = Button.new()
	pause_button.text = "Pause"
	pause_button.custom_minimum_size = Vector2(70, 0)
	pause_button.pressed.connect(_on_pause_pressed)
	button_box.add_child(pause_button)

	reset_button = Button.new()
	reset_button.text = "Reset"
	reset_button.custom_minimum_size = Vector2(70, 0)
	reset_button.pressed.connect(_on_reset_pressed)
	button_box.add_child(reset_button)

	var separator3 = HSeparator.new()
	vbox.add_child(separator3)

	# Placement buttons
	place_arm_button = Button.new()
	place_arm_button.text = "Place Arm (Click)"
	place_arm_button.toggle_mode = true
	place_arm_button.toggled.connect(_on_place_arm_toggled)
	vbox.add_child(place_arm_button)

	# Instructions
	var separator4 = HSeparator.new()
	vbox.add_child(separator4)

	var instructions = Label.new()
	instructions.text = "Objective: Move all atoms\nfrom green zone to red zone\n\nCamera Controls:\n- Right/Middle Mouse: Pan\n- Mouse Wheel: Zoom\n\nArm Program:\n- Grab atom\n- Rotate 180°\n- Drop atom\n- Rotate back\n- Repeat"
	instructions.autowrap_mode = TextServer.AUTOWRAP_WORD
	instructions.custom_minimum_size = Vector2(230, 0)
	vbox.add_child(instructions)

func set_game_manager(gm: GameManager):
	game_manager = gm
	if game_manager:
		game_manager.cycle_completed.connect(_on_cycle_completed)
		game_manager.level_completed.connect(_on_level_completed)

func _on_play_pressed():
	if game_manager:
		game_manager.play()
		info_label.text = "Simulation running..."

func _on_pause_pressed():
	if game_manager:
		game_manager.pause()
		info_label.text = "Simulation paused"

func _on_reset_pressed():
	if game_manager:
		game_manager.reset()
		cycle_label.text = "Cycles: 0"
		info_label.text = "Simulation reset"

func _on_place_arm_toggled(toggled: bool):
	print("Place arm button toggled: ", toggled)
	if game_manager:
		game_manager.placement_mode = "arm" if toggled else ""
		print("Set placement_mode to: ", game_manager.placement_mode)
		info_label.text = "Click hex to place arm" if toggled else "Arm placement disabled"
	else:
		print("ERROR: game_manager is null!")

func _on_cycle_completed():
	if game_manager:
		cycle_label.text = "Cycles: " + str(game_manager.cycle_count)

func _on_level_completed():
	info_label.text = "LEVEL COMPLETE!"
	var completion_label = Label.new()
	completion_label.text = "LEVEL COMPLETED!"
	completion_label.position = Vector2(640, 360)
	completion_label.add_theme_font_size_override("font_size", 48)
	completion_label.add_theme_color_override("font_color", Color(0.2, 1.0, 0.2))
	add_child(completion_label)
