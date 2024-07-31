class_name EvilLightCone extends Node2D

@onready var area: Area2D = $Area2D
@export var damage: float = 10 # PER FRAME!

@export var nonpossessed_light_cone_tex: Texture2D
@export var possessed_light_cone_tex: Texture2D

@onready var sprite: Sprite2D = $Sprite2D


var do_damage_to_player: bool = true
var possessed: bool = false

# Called when the node enters the scene tree for the first time.
func _ready():
	sprite.texture = nonpossessed_light_cone_tex


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta):
	var overlapping_bodies = area.get_overlapping_bodies()
	for b in overlapping_bodies:
		# print("OVERLAPPING BODIES: %s" % area.get_overlapping_bodies())
		on_area_overlaps_body(b)
	
	var overlapping_areas = area.get_overlapping_areas()
	for a in overlapping_areas:
		# print("OVERLAPPING AREAS: %s" % area.get_overlapping_areas())
		on_area_overlaps_area(a)


func on_area_overlaps_body(body: PhysicsBody2D):
	if body is Player and not possessed and not body.disabled:
		print("PLAYER IS OCCUPYING MY AREA! SOUND THE ALARMS")
		body.damage(damage)

func on_area_overlaps_area(area: Area2D):
	if area is EnemyHitbox and possessed and area.get_parent() != self.get_parent():
		print("enemy %s damaged enemy %s yaurgh" % [get_parent(), area.get_parent()])
		area.get_parent().damage(damage)

func possess():
	possessed = true
	sprite.texture = possessed_light_cone_tex