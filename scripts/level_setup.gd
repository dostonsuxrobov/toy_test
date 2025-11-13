extends Node
# This script sets up the initial level with a ball and a button

@onready var workspace: Workspace = get_node("/root/Main/Workspace")
@onready var game_manager: GameManager = get_node("/root/Main/GameManager")

func _ready() -> void:
	await get_tree().process_frame
	await get_tree().process_frame
	setup_first_level()

func setup_first_level() -> void:
	if not workspace:
		return

	# Place the starting ball on the left side, elevated
	var ball = workspace.create_ball_part()
	ball.position = Vector3(-8, 3, 0)
	workspace.add_child(ball)
	# Don't add to game manager parts list (it's free/provided)

	# Place the goal button on the right side
	var button = workspace.create_button_part()
	button.position = Vector3(8, 0, 0)
	workspace.add_child(button)
	# Don't add to game manager parts list (it's the goal, not a cost)

	print("Level setup complete!")
	print("Instructions:")
	print("- Click a part in the left menu")
	print("- Click in the 3D view to place it")
	print("- Build a chain reaction from the blue ball to the red button")
	print("- Press 'Test Machine' to see it run!")
	print("")
	print("Camera Controls:")
	print("- Middle mouse button: Rotate camera")
	print("- Mouse wheel: Zoom in/out")
	print("- WASD: Pan camera")
