class_name ExitDoorShadow extends Area2D

@onready var collision_polygon: CollisionPolygon2D = $CollisionPolygon2D

var clicked_this_frame: bool = false

var is_enabled: bool = true

var using_polygon: bool = true

var owned_by_enemy: bool = false

signal player_entered # emitted when the player enters the exit door shadow

# Called when the node enters the scene tree for the first time.
func _ready():
	input_event.connect(_on_input_event)

	mouse_entered.connect(_on_mouse_enter)
	mouse_exited.connect(_on_mouse_exit)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if is_enabled:
		pass
	else:
		pass

func _on_mouse_enter():
	pass
	# polygon.material.set_shader_parameter("do_outline", true)
	get_parent().mouse_entered()
	

func _on_mouse_exit():
	pass
	# polygon.material.set_shader_parameter("do_outline", false)
	get_parent().mouse_exited()

func _on_input_event(viewport: Viewport, event: InputEvent, shape_idx: int):
	if event is InputEventMouseButton and event.is_pressed():
		if event.button_index == MOUSE_BUTTON_LEFT:
			clicked_this_frame = true
			get_parent().player.clicked_on_shadow(self)
			print("clicked!")
	else:
		clicked_this_frame = false

func enable() -> void:
	is_enabled = true
	input_pickable = true
	collision_polygon.disabled = false
	visible = true

func disable() -> void:
	is_enabled = false
	input_pickable = false
	collision_polygon.disabled = true
	visible = false
