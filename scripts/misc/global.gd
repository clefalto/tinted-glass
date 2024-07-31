extends Node


# global player data tracking
var player: Player

var player_powerup_sound: AudioStream = preload("res://assets/sounds/powerup.wav")

var player_fragments: int = 0
var level_fragments: int

var current_enemies: int
var level_enemies: int

var defeated_all_enemies: bool = false
var collected_all_fragments: bool = false

var player_dead: bool = false

# Called when the node enters the scene tree for the first time.
func _ready():
	player = get_player()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func get_player():
	return Util.find(get_tree().root, Player)

func decrement_enemies() -> void:
	current_enemies = clamp(current_enemies - 1, 0, level_enemies)
	if level_enemies == 0:
		defeated_all_enemies = true

func increase_fragment_count() -> void:
	player_fragments = clamp(player_fragments + 1, 0, level_fragments)
	if player_fragments == level_fragments:
		collected_all_fragments = true
		get_player().empower()
		play_sound(player_powerup_sound)

func on_level_reset():
	player = get_player()
	player_fragments = 0
	defeated_all_enemies = false
	collected_all_fragments = false
	player_dead = false

func play_sound(stream: AudioStream, random_pitch: bool = false, random_range_start: float = 0.75, random_range_end: float = 1.25):
	var stackable_sound = preload("res://scenes/misc/stackable_sound.tscn")
	var sound_node = stackable_sound.instantiate()
	sound_node.stream = stream
	add_child(sound_node)
	if random_pitch:
		sound_node.pitch_scale = randf_range(random_range_start, random_range_end)
	sound_node.play()