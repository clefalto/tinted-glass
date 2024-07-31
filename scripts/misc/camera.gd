extends Camera2D

# https://kidscancode.org/godot_recipes/3.x/2d/screen_shake/index.html

@export var decay = 0.8
@export var max_offset = Vector2(5, 5)

var trauma = 0.0
var trauma_power = 2

var decay_trauma: bool = true


# Called when the node enters the scene tree for the first time.
func _ready():
	randomize()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if trauma:
		if decay_trauma:
			trauma = max(trauma - decay * delta, 0)
		shake()

func add_trauma(amount):
	trauma = min(trauma + amount, 1.0)


func shake():
	var amount = pow(trauma, trauma_power)
	offset.x = max_offset.x * amount * randf_range(-1, 1)
	offset.y = max_offset.y * amount * randf_range(-1, 1)