extends Node3D

@onready var camera_controller = $CameraController
@onready var building_manager = $BuildingManager
@onready var terrain = $Terrain

func _ready():
	# Initialize building manager with camera and terrain
	if building_manager and camera_controller:
		building_manager.set_camera(camera_controller.get_camera())
	if building_manager and terrain:
		building_manager.set_terrain(terrain)
