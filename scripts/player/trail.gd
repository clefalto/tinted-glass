extends Line2D

var point_radius: int = 2
var num_points: int = 6
var starting_position: Vector2 = Vector2.ZERO

@export var shadow_color: Color = Util.default_shadow_color

# got the logic for this from a youtube video but i can't find it again :(

# Called when the node enters the scene tree for the first time.
func _ready():
	default_color = shadow_color
	# global_position = get_parent().global_position
	for i in range(num_points):
		add_point(Vector2(starting_position.x + i * point_radius, starting_position.y + i * point_radius))
	

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	# var mouse_pos = get_global_mouse_position()
	set_point_position(0, to_global(Vector2.ZERO))
	for point_idx in range(num_points):
		if point_idx == 0:
			continue
		var current_point_position: Vector2 = to_global(get_point_position(point_idx))
		var ahead_point_pos: Vector2 = to_global(get_point_position(point_idx - 1))
		var new_point_pos: Vector2 = ahead_point_pos - (current_point_position.direction_to(ahead_point_pos) * point_radius)
		set_point_position(point_idx, to_local(new_point_pos))


func _draw():
	pass
	for p in range(num_points):
		if p == 0: continue
		var point_position: Vector2 = get_point_position(p)
		draw_circle(to_local(point_position), lerp(5.0, 0.5, float(p)/num_points), shadow_color)
