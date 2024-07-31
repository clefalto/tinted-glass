class_name ShadowFragment extends Area2D

@export var pickup_sound: AudioStream = load("res://assets/sounds/pickup_fragment.wav")

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func _physics_process(delta):
	var overlapping_bodies = get_overlapping_bodies()
	for b in overlapping_bodies:
		if b is Player:
			b.collect_fragment(self)
			Global.increase_fragment_count()
			Global.play_sound(pickup_sound)
			queue_free()
