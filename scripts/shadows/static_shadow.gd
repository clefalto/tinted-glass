class_name StaticShadow extends Area2D

# previously was a shadow cast without an object but is now just the starting shadow that the player starts in for each level

@export var outline_material: Material
@export_color_no_alpha var shadow_color: Color

@onready var collision_polygon: CollisionPolygon2D = $CollisionPolygon2D
@onready var polygon: Polygon2D = $Polygon2D
@onready var outline_polygon: Polygon2D = $Outline
@onready var start_animation_sprite: AnimatedSprite2D = $StartSprite

@export var player: Player

var clicked_this_frame: bool = false

var using_polygon: bool = true

var is_enabled: bool = false

var owned_by_enemy: bool = false

# Called when the node enters the scene tree for the first time.
func _ready():
	input_event.connect(_on_input_event)

	mouse_entered.connect(_on_mouse_enter)
	mouse_exited.connect(_on_mouse_exit)

	var expanded_outline_polygon: PackedVector2Array = []
	for v in polygon.polygon:
		expanded_outline_polygon.push_back(v + Vector2(sign(v.x), sign(v.y)))
	
	outline_polygon.polygon = expanded_outline_polygon
	outline_polygon.visible = false

	player = Global.get_player()

	start_animation_sprite.visible = true
	self.disable()
	polygon.visible = false
	player.visible = false
	player.process_mode = PROCESS_MODE_DISABLED
	start_animation_sprite.play("default")
	start_animation_sprite.animation_finished.connect(on_finish_land_animation)

func on_finish_land_animation():
	start_animation_sprite.visible = false
	self.enable()
	polygon.visible = true
	player.visible = true
	player.process_mode = PROCESS_MODE_INHERIT

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if is_enabled:
		pass
	else:
		pass

func _on_mouse_enter():
	pass
	# polygon.material.set_shader_parameter("do_outline", true)
	outline_polygon.visible = true
	

func _on_mouse_exit():
	pass
	# polygon.material.set_shader_parameter("do_outline", false)
	outline_polygon.visible = false

func _on_input_event(viewport: Viewport, event: InputEvent, shape_idx: int):
	if event is InputEventMouseButton and event.is_pressed():
		if event.button_index == MOUSE_BUTTON_LEFT:
			clicked_this_frame = true
			player.clicked_on_shadow(self)
			print("clicked!")
	else:
		clicked_this_frame = false

func enable() -> void:
	is_enabled = true
	input_pickable = true
	collision_polygon.disabled = false

func disable() -> void:
	is_enabled = false
	input_pickable = false
	collision_polygon.disabled = true
