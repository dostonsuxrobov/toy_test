extends CanvasLayer

@onready var building_btn = $Panel/HBoxContainer/BuildingButton
@onready var road_btn = $Panel/HBoxContainer/RoadButton
@onready var lake_btn = $Panel/HBoxContainer/LakeButton
@onready var clear_btn = $Panel/HBoxContainer/ClearButton
@onready var info_label = $InfoLabel

var main_scene: Node3D

func _ready():
	# Get reference to main scene
	main_scene = get_parent()

	# Connect buttons
	building_btn.pressed.connect(_on_building_pressed)
	road_btn.pressed.connect(_on_road_pressed)
	lake_btn.pressed.connect(_on_lake_pressed)
	clear_btn.pressed.connect(_on_clear_pressed)

	update_info()

func _process(_delta):
	update_info()

func _on_building_pressed():
	main_scene._on_building_button_pressed()
	update_button_states(building_btn)

func _on_road_pressed():
	main_scene._on_road_button_pressed()
	update_button_states(road_btn)

func _on_lake_pressed():
	main_scene._on_lake_button_pressed()
	update_button_states(lake_btn)

func _on_clear_pressed():
	main_scene._on_clear_button_pressed()
	update_button_states(clear_btn)

func update_button_states(active_button):
	# Reset all button colors
	building_btn.modulate = Color.WHITE
	road_btn.modulate = Color.WHITE
	lake_btn.modulate = Color.WHITE
	clear_btn.modulate = Color.WHITE

	# Highlight active button
	if active_button:
		active_button.modulate = Color(0.7, 1.0, 0.7)

func update_info():
	var mode_text = ""
	match main_scene.current_building_type:
		main_scene.BuildingType.LARGE_BUILDING:
			mode_text = "Mode: Building | Left Click: Place | Middle Mouse: Rotate Camera | Scroll: Zoom"
		main_scene.BuildingType.ROAD:
			mode_text = "Mode: Road | Left Click: Place | Middle Mouse: Rotate Camera | Scroll: Zoom"
		main_scene.BuildingType.LAKE:
			mode_text = "Mode: Lake | Left Click: Place | Middle Mouse: Rotate Camera | Scroll: Zoom"
		_:
			mode_text = "Mode: Select | Left Click: Select Object | Middle Mouse: Rotate Camera | Scroll: Zoom"

	info_label.text = mode_text
