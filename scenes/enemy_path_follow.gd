class_name Enemy extends PathFollow2D

@export var speed: float = 50.0

@onready var path: Path2D = get_parent()
@onready var evil_light_cone: EvilLightCone = get_node("EvilLightCone")
@onready var sprite: AnimatedSprite2D = get_node("AnimatedSprite2D")

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	var baked = path.curve.sample_baked_with_rotation(progress)
	evil_light_cone.rotation = baked.get_rotation()
	if baked.y.x < 0:
		sprite.flip_h = true
	else:
		sprite.flip_h = false


func _physics_process(delta):
	progress += delta * speed
	sprite.animation = "walk"
