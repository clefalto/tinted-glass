class_name EvilLightCone extends Node2D

@onready var area: Area2D = $Area2D
@export var damage: float = 5 # PER FRAME!

# Called when the node enters the scene tree for the first time.
func _ready():
	pass


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta):
	var overlapping_bodies = area.get_overlapping_bodies()
	for b in overlapping_bodies:
		_on_area_overlaps_body(b)
	
	var overlapping_areas = area.get_overlapping_areas()
	for a in overlapping_areas:
		pass
	

	# rotate(0.05)


func _on_area_overlaps_body(body: PhysicsBody2D):
	if body is Player:
		print("PLAYER IS OCCUPYING MY AREA! SOUND THE ALARMS")
		body.damage(damage)