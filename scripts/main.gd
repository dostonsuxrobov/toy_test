extends Node2D

# Main scene setup

@onready var game_manager: GameManager
@onready var ui_controller: UIController

func _ready():
	# Get references
	game_manager = $GameManager
	ui_controller = $UIController

	# Connect UI to game manager
	ui_controller.set_game_manager(game_manager)
