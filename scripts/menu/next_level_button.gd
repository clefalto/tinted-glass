extends Button

@onready var destination_position: Vector2 = position

var button_press_sound: AudioStream = preload("res://assets/sounds/menu_select.wav")

var revealed: bool = false

# Called when the node enters the scene tree for the first time.
func _ready():
	visible = false


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if revealed:
		var dist_to_destination = position.distance_to(destination_position)
		position = position.move_toward(destination_position, delta * 5 * dist_to_destination)


func _on_button_down():
	LevelManager.go_to_next_level()
	Global.play_sound(button_press_sound, true)


func reveal():
	position.x = 320 + 30
	visible = true
	revealed = true
	