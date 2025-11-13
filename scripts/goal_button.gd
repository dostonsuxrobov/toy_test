extends Area3D

var is_pressed: bool = false
var game_manager: GameManager

func _ready() -> void:
	body_entered.connect(_on_body_entered)
	await get_tree().process_frame
	game_manager = get_node("/root/Main/GameManager")

func _on_body_entered(body: Node3D) -> void:
	if is_pressed:
		return

	if game_manager and game_manager.current_state == GameManager.GameState.TEST:
		is_pressed = true
		press_button()

func press_button() -> void:
	# Visual feedback - move button down
	var button_mesh = get_child(1)  # The button cylinder
	if button_mesh:
		var tween = create_tween()
		tween.tween_property(button_mesh, "position:y", 0.05, 0.2)

	# Notify game manager
	if game_manager:
		game_manager.on_goal_achieved()

	print("Button pressed! Goal achieved!")
