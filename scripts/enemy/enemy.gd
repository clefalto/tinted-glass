class_name Enemy extends Node2D

@export var speed: float = 50.0

@export var path: Path2D
@export var follow_path: bool
@onready var evil_light_cone: EvilLightCone = get_node("EvilLightCone")
@onready var sprite: AnimatedSprite2D = get_node("AnimatedSprite2D")

@onready var shadow_particles: GPUParticles2D = $GPUParticles2D

@export var death_sound: AudioStream = preload("res://assets/sounds/enemy_die.wav")

var path_follow: PathFollow2D # parent if there is a path defined

var max_health: float = 100.0
var current_health: float = max_health

var is_possessed: bool = false
var possession_max_health: float = 100.0
var possession_current_health: float = possession_max_health
var possession_decay_rate: float = 0.125

# Called when the node enters the scene tree for the first time.
func _ready():
	if follow_path:
		path_follow = get_parent()
	$EnemyShadow.possessed.connect(possess)
	shadow_particles.emitting = false

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if current_health == 0.0:
		die()
	if follow_path and not is_possessed:
		var baked = path.curve.sample_baked_with_rotation(path_follow.progress)
		evil_light_cone.rotation = baked.get_rotation()
		if baked.y.x < 0:
			sprite.flip_h = true
		else:
			sprite.flip_h = false
	elif is_possessed:
		global_position = global_position.move_toward(get_global_mouse_position(), 10.0 * delta)
		if position.direction_to(get_global_mouse_position()) != Vector2.ZERO:
			sprite.animation = "walk_possessed"
		sprite.flip_h = global_position.direction_to(get_global_mouse_position()).x < 0
		sprite.offset = Vector2(randf_range(-1, 1), randf_range(-1, 1))

		evil_light_cone.rotation = global_position.direction_to(get_global_mouse_position()).angle() + deg_to_rad(90)

		possession_current_health = clamp(possession_current_health - possession_decay_rate, 0.0, possession_max_health)
		if possession_current_health == 0.0:
			die()
		

func _physics_process(delta):
	if follow_path and not is_possessed:
		path_follow.progress += delta * speed
		sprite.animation = "walk"


func damage(amount: float):
	current_health = clamp(current_health - amount, 0.0, max_health)

func possess(shadow: Area2D):
	print("ooh aah i am being possessed!!!! scary spooky!")
	is_possessed = true
	Global.get_player().begin_possessing_enemy(self)
	sprite.animation = "idle_possessed"
	evil_light_cone.possess()
	shadow_particles.emitting = true

func die():
	Global.decrement_enemies()
	Global.play_sound(death_sound)
	queue_free()
