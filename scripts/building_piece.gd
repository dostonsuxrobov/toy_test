extends Node3D
class_name BuildingPiece

enum PieceType {
	WALL,
	TOWER,
	GATE,
	DECORATION
}

@export var piece_type: PieceType = PieceType.WALL
@export var piece_height: float = 3.0
@export var piece_width: float = 2.0

var is_preview: bool = false
var is_valid_placement: bool = true

func _ready():
	pass

func set_preview_mode(preview: bool):
	is_preview = preview
	update_visual()

func set_valid_placement(valid: bool):
	is_valid_placement = valid
	update_visual()

func update_visual():
	# Update material based on preview/valid state
	for child in get_children():
		if child is MeshInstance3D:
			var material: StandardMaterial3D
			if is_preview:
				material = StandardMaterial3D.new()
				material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
				material.albedo_color = Color(1, 1, 1, 0.5) if is_valid_placement else Color(1, 0, 0, 0.5)
			else:
				material = create_final_material()
			child.material_override = material

func create_final_material() -> StandardMaterial3D:
	var material = StandardMaterial3D.new()
	# Stone-like color
	material.albedo_color = Color(0.7, 0.65, 0.6)
	material.roughness = 0.8
	material.metallic = 0.1
	return material

func get_piece_data() -> Dictionary:
	return {
		"type": piece_type,
		"position": position,
		"rotation": rotation,
		"scale": scale
	}

static func from_data(data: Dictionary) -> BuildingPiece:
	var piece = BuildingPiece.new()
	piece.piece_type = data.type
	piece.position = data.position
	piece.rotation = data.rotation
	piece.scale = data.scale
	return piece
