extends Node

@onready var building_manager = $"../BuildingManager"
@onready var ui_manager = $"../UI"

const SAVE_PATH = "user://tiny_glade_save.json"

func _ready():
	if ui_manager:
		ui_manager.build_mode_changed.connect(_on_build_mode_changed)
		ui_manager.save_requested.connect(_on_save_requested)
		ui_manager.load_requested.connect(_on_load_requested)

func _on_build_mode_changed(mode: int):
	if mode == -1:
		# Clear wall chain
		if building_manager:
			building_manager.clear_wall_chain()
	else:
		if building_manager:
			building_manager.set_build_mode(mode)

func _on_save_requested():
	if not building_manager:
		return

	var save_data = building_manager.get_save_data()
	var file = FileAccess.open(SAVE_PATH, FileAccess.WRITE)
	if file:
		file.store_string(JSON.stringify(save_data))
		file.close()
		print("Game saved successfully!")

func _on_load_requested():
	if not building_manager:
		return

	if FileAccess.file_exists(SAVE_PATH):
		var file = FileAccess.open(SAVE_PATH, FileAccess.READ)
		if file:
			var json_string = file.get_as_text()
			file.close()

			var json = JSON.new()
			var parse_result = json.parse(json_string)
			if parse_result == OK:
				var data = json.get_data()
				building_manager.load_from_data(data)
				print("Game loaded successfully!")
			else:
				print("Failed to parse save file")
	else:
		print("No save file found")

func _input(event):
	# Keyboard shortcuts
	if event is InputEventKey and event.pressed:
		match event.keycode:
			KEY_1:
				_on_build_mode_changed(0)  # WALL
				ui_manager.update_mode_label(0)
			KEY_2:
				_on_build_mode_changed(1)  # TOWER
				ui_manager.update_mode_label(1)
			KEY_3:
				_on_build_mode_changed(2)  # GATE
				ui_manager.update_mode_label(2)
			KEY_X:
				_on_build_mode_changed(4)  # DELETE
				ui_manager.update_mode_label(4)
			KEY_ESCAPE:
				_on_build_mode_changed(-1)  # Clear chain
