extends Control

var start_game_sound: AudioStream = preload("res://assets/sounds/menu_select.wav")

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func _unhandled_input(event):
	if event is InputEventMouseButton:
		print("A")
		if not event.canceled and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
			Global.play_sound(start_game_sound, true)
			LevelManager.begin_game()
