extends Control

signal build_mode_changed(mode)
signal save_requested()
signal load_requested()

@onready var mode_label = $MarginContainer/VBoxContainer/ModeLabel
@onready var wall_btn = $MarginContainer/VBoxContainer/ButtonContainer/WallButton
@onready var tower_btn = $MarginContainer/VBoxContainer/ButtonContainer/TowerButton
@onready var gate_btn = $MarginContainer/VBoxContainer/ButtonContainer/GateButton
@onready var delete_btn = $MarginContainer/VBoxContainer/ButtonContainer/DeleteButton
@onready var clear_btn = $MarginContainer/VBoxContainer/ControlsContainer/ClearButton
@onready var save_btn = $MarginContainer/VBoxContainer/ControlsContainer/SaveButton
@onready var load_btn = $MarginContainer/VBoxContainer/ControlsContainer/LoadButton
@onready var help_label = $MarginContainer/VBoxContainer/HelpLabel

var current_mode: int = 0  # BuildManager.BuildMode

func _ready():
	# Connect button signals
	wall_btn.pressed.connect(_on_wall_button_pressed)
	tower_btn.pressed.connect(_on_tower_button_pressed)
	gate_btn.pressed.connect(_on_gate_button_pressed)
	delete_btn.pressed.connect(_on_delete_button_pressed)
	clear_btn.pressed.connect(_on_clear_button_pressed)
	save_btn.pressed.connect(_on_save_button_pressed)
	load_btn.pressed.connect(_on_load_button_pressed)

	update_mode_label(0)  # WALL mode

func _on_wall_button_pressed():
	build_mode_changed.emit(0)  # BuildMode.WALL
	update_mode_label(0)

func _on_tower_button_pressed():
	build_mode_changed.emit(1)  # BuildMode.TOWER
	update_mode_label(1)

func _on_gate_button_pressed():
	build_mode_changed.emit(2)  # BuildMode.GATE
	update_mode_label(2)

func _on_delete_button_pressed():
	build_mode_changed.emit(4)  # BuildMode.DELETE
	update_mode_label(4)

func _on_clear_button_pressed():
	# Clear wall chain
	build_mode_changed.emit(-1)

func _on_save_button_pressed():
	save_requested.emit()

func _on_load_button_pressed():
	load_requested.emit()

func update_mode_label(mode: int):
	current_mode = mode
	var mode_text = ""
	match mode:
		0:  # WALL
			mode_text = "Wall Mode"
			help_label.text = "Click to place wall points. Click again to continue the wall chain."
		1:  # TOWER
			mode_text = "Tower Mode"
			help_label.text = "Click to place towers."
		2:  # GATE
			mode_text = "Gate Mode"
			help_label.text = "Click to place gates."
		4:  # DELETE
			mode_text = "Delete Mode"
			help_label.text = "Click on buildings to delete them."
		_:
			mode_text = "Unknown Mode"

	mode_label.text = "Current Mode: " + mode_text
