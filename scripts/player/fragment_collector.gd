class_name FragmentCollector extends Area2D

@export var strength: float = 10.0

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func _physics_process(delta):
	var overlapping_areas = get_overlapping_areas()
	for a in overlapping_areas:
		if a is ShadowFragment:
			a.global_position = a.global_position.move_toward(global_position, delta * strength)