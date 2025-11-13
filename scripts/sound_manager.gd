extends Node
class_name SoundManager

# Sound categories
enum SoundType {
	WOOD_IMPACT,
	METAL_IMPACT,
	PLASTIC_IMPACT,
	GEAR_ROTATION,
	BUTTON_PRESS,
	PART_BREAK
}

# Audio players pool
var audio_players: Array[AudioStreamPlayer3D] = []
var max_concurrent_sounds: int = 20

func _ready() -> void:
	# Pre-create audio player pool
	for i in range(max_concurrent_sounds):
		var player = AudioStreamPlayer3D.new()
		player.bus = "SFX"
		add_child(player)
		audio_players.append(player)

func play_sound(sound_type: SoundType, position: Vector3, volume_db: float = 0.0) -> void:
	# Find available audio player
	var player = get_available_player()
	if not player:
		return

	# Get the sound stream based on type
	var stream = get_sound_stream(sound_type)
	if not stream:
		print("No sound stream for type: ", sound_type)
		return

	# Configure and play
	player.stream = stream
	player.global_position = position
	player.volume_db = volume_db
	player.pitch_scale = randf_range(0.9, 1.1)  # Slight pitch variation
	player.play()

func play_collision_sound(position: Vector3, velocity: float, material_type: String = "default") -> void:
	# Determine sound type based on material
	var sound_type = SoundType.WOOD_IMPACT
	match material_type:
		"metal":
			sound_type = SoundType.METAL_IMPACT
		"plastic":
			sound_type = SoundType.PLASTIC_IMPACT
		_:
			sound_type = SoundType.WOOD_IMPACT

	# Calculate volume based on velocity
	var volume = clamp(-20.0 + velocity * 5.0, -30.0, 5.0)
	play_sound(sound_type, position, volume)

func get_available_player() -> AudioStreamPlayer3D:
	for player in audio_players:
		if not player.playing:
			return player
	# If all busy, return the first one (will interrupt)
	return audio_players[0]

func get_sound_stream(sound_type: SoundType) -> AudioStream:
	# This would load actual audio files
	# For now, we'll use procedurally generated sounds or return null
	# TODO: Load actual sound files when available

	# Example paths (not yet implemented):
	# match sound_type:
	#     SoundType.WOOD_IMPACT:
	#         return load("res://sounds/wood_impact.ogg")
	#     SoundType.METAL_IMPACT:
	#         return load("res://sounds/metal_impact.ogg")

	return null  # No sounds loaded yet

# Helper function to create simple procedural sound (placeholder)
func create_procedural_impact_sound() -> AudioStream:
	# This would create a simple procedural sound
	# Godot doesn't have built-in procedural audio generation,
	# so this is a placeholder for when actual sound files are added
	return null
