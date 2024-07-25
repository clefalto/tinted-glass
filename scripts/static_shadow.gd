class_name StaticShadow extends Node2D

@export var outline_material: Material
@export_color_no_alpha var shadow_color: Color

@onready var area: Area2D = $Area2D
@onready var collision_polygon: CollisionPolygon2D = $Area2D/CollisionPolygon2D
@onready var polygon: Polygon2D = $Polygon2D

@export var player: Player

var clicked_this_frame: bool = false

# Called when the node enters the scene tree for the first time.
func _ready():
	area.input_event.connect(_on_input_event)

	area.mouse_entered.connect(_on_mouse_enter)
	area.mouse_exited.connect(_on_mouse_exit)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func _on_mouse_enter():
	pass
	# polygon.material = outline_material

func _on_mouse_exit():
	pass
	# polygon.material = null

func _on_input_event(viewport: Viewport, event: InputEvent, shape_idx: int):
	if event is InputEventMouseButton and event.is_pressed():
		if event.button_index == MOUSE_BUTTON_LEFT:
			clicked_this_frame = true
			player.clicked_on_shadow(area)
			print("clicked!")
	else:
		clicked_this_frame = false
