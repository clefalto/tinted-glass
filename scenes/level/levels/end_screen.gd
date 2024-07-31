extends Control

var accept_sound: AudioStream = preload("res://assets/sounds/menu_select.wav")

func _ready():
	pass

func _process(delta):
	pass

func _input(event):
	if event is InputEventMouseButton:
		if not event.canceled and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
			Global.play_sound(accept_sound, true)
			LevelManager.return_to_menu()