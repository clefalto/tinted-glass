extends TextureRect

@export var damage_texture_array: Array[Texture2D]
# @onready var audio_stream_player: AudioStreamPlayer2D = $AudioStreamPlayer2D

# Called when the node enters the scene tree for the first time.
func _ready():
	visible = false


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	var player = Global.get_player()
	if player.current_health == player.max_health:
		visible = false
		# audio_stream_player.volume_db = -60
	else:
		visible = true
		# audio_stream_player.volume_db = player.current_health - 160
		var slope = 1.0 * (damage_texture_array.size() - 1) / (player.max_health)
		var idx: int = floor(slope * (player.current_health))
		texture = damage_texture_array[idx]

		

