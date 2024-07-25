class_name Player extends CharacterBody2D

@export var TEMPORARY_default_inhabited_shadow: Area2D
var inhabited_shadow: Area2D

var destination_position: Vector2
var interpolated_position: Vector2
var safe_interpolated_position: Vector2

var global_shadow_polygon: PackedVector2Array

var jump_end_position: Vector2
var should_be_jumping: bool = false

@onready var shape_cast: ShapeCast2D = $ShapeCast2D

@export var max_health: float = 100
@export var health_regen_rate: float = 5.0
var current_health: float = max_health
var time_since_last_damaged: float = 0.0

var screen_bounds: Vector2 = Vector2(320, 180)


# Called when the node enters the scene tree for the first time.
func _ready():
	inhabited_shadow = TEMPORARY_default_inhabited_shadow
	global_shadow_polygon = make_shadow_polygon_global(inhabited_shadow)
	

func _process(delta):
	# queue_redraw()
	pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta):

	if time_since_last_damaged > 1.0:
		current_health = clampf(current_health + health_regen_rate, 0.0, max_health)

	time_since_last_damaged += delta

	# update shadow polygon in case it moves
	global_shadow_polygon = make_shadow_polygon_global(inhabited_shadow)

	# if is_inside_shadow(inhabited_shadow):
	if is_inside_shadow(inhabited_shadow):
		if should_be_jumping:
			should_be_jumping = false
		# destination_position = get_global_mouse_position()
		# destination_position = clamp_to_current_shadow(destination_position)

		# # interpolating the speed at which the player moves towards the mouse based on how far away the targeted position is
		# var dist_weight = position.distance_to(destination_position)

		# interpolated_position = position.move_toward(destination_position, 25.0)

		# # use shape cast to ensure we don't get stuck WITHIN a shadow
		# shape_cast.target_position = to_local(interpolated_position)
		# var safe_fraction = shape_cast.get_closest_collision_safe_fraction()
		# safe_interpolated_position = lerp(position, interpolated_position, safe_fraction)

		# velocity = safe_interpolated_position - position

		destination_position = get_global_mouse_position()
		var target_direction = position.direction_to(destination_position) * 25

		velocity = target_direction

		# position = clamp_to_current_shadow(position)


		# velocity = position - interpolated_position
		# velocity = interpolated_position - position
		
		# var polygon_node: CollisionPolygon2D = find(inhabited_shadow, CollisionPolygon2D)
		# var polygon: PackedVector2Array = polygon_node.polygon

		# var offset_polygon: PackedVector2Array = []
		# for p in polygon:
		# 	offset_polygon.append(polygon_node.to_global(p))

		# if not Geometry2D.is_point_in_polygon(interpolated_position, global_shadow_polygon):
		# 	velocity = Vector2.ZERO
	
	elif should_be_jumping: # outside shadow but is allowed to be outside shadow
		destination_position = jump_end_position

		velocity = (destination_position - position).normalized() * 100.0

	else: # outside shadow and should not be outside shadow
		position = clamp_to_current_shadow(position)

		# push player back into shadow
		velocity = -velocity

	move_and_slide()

	

	queue_redraw()




func damage(amount: float) -> void:
	current_health = clampf(current_health - amount, 0.0, max_health)
	time_since_last_damaged = 0.0

func _draw():
	# draw_circle(to_local(destination_position), 1, Color.GREEN)
	# draw_circle(to_local(interpolated_position), 1, Color.RED)
	# draw_circle(to_local(jump_end_position), 1, Color.BLUE)
	# draw_circle(to_local(safe_interpolated_position), 2, Color.PINK)

	# draw_line(to_local(position), to_local(interpolated_position), Color.WHITE, 1.0)

	# draw_line(to_local(position), to_local(get_global_mouse_position()), Color.YELLOW, 1.0)

	# draw_circle(to_local(clamp_to_current_shadow(position)), 1, Color.PURPLE)

	# var to_localed_shadow_polygon = []
	# for p in global_shadow_polygon:
	# 	to_localed_shadow_polygon.push_back(to_local(p))

	# draw_colored_polygon(to_localed_shadow_polygon, Color.GREEN)
	pass


func clicked_on_shadow(area: Area2D):
	shape_cast.target_position = to_local(get_global_mouse_position())

	var jump_direction = position.direction_to(shape_cast.target_position)
	shape_cast.add_exception(inhabited_shadow)
	shape_cast.force_shapecast_update()

	# var closest_shadow_point = Vector2.INF
	# var closest_wall_point = Vector2.INF

	var shadow_point: Vector2

	var hit_wall: bool = false
	var hit_shadow_before_wall: bool = false

	while shape_cast.get_collision_count() > 0:
		var hit_wall_this_collision: bool = false
		print("COLLISION COUNT: %s" % shape_cast.get_collision_count())
		for i in range(shape_cast.get_collision_count()):
			var collider = shape_cast.get_collider(i)
			print("collider is %s, target area is %s, and collision_point is %v" % [collider, area, shape_cast.get_collision_point(i)])
			if collider is Area2D and collider == area:
				# var shadow_point = shape_cast.get_collision_point(i)
				shadow_point = shape_cast.get_collision_point(i)
				if not hit_wall:
					hit_shadow_before_wall = true
				# if position.distance_to(shadow_point) < position.distance_to(closest_shadow_point):
				# 	closest_shadow_point = shadow_point
				# 	print("set shadow point to %s" % shadow_point)
			if collider is StaticBody2D:
				# wall_point = shape_cast.get_collision_point(i)
				# if position.distance_to(wall_point) < position.distance_to(closest_wall_point):
				# 	closest_wall_point = wall_point
				# 	print("set wall point to %s" % wall_point)
				hit_wall_this_collision = true
			
			if hit_wall_this_collision and hit_shadow_before_wall:
				hit_wall = true
			shape_cast.add_exception(collider)

		shape_cast.force_shapecast_update()

	
	
	# if not wall_point and shadow_point:
	# 	jump_to_shadow(area, shadow_point)
	# if wall_point and shadow_point:
	# 	if position.distance_to(wall_point) > position.distance_to(shadow_point):
	# 		jump_to_shadow(area, shadow_point)
	
	# if position.distance_to(closest_wall_point) > position.distance_to(closest_shadow_point):
	# 	jump_to_shadow(area, closest_shadow_point)

	if not hit_wall: 
		jump_to_shadow(area, shadow_point)
	
	shape_cast.clear_exceptions()

	# shape_cast.add_exception(inhabited_shadow)
	# shape_cast.force_shapecast_update()
	# var collider = shape_cast.get_collider(0)
	# if not collider:
	# 	jump_to_shadow(area)

func jump_to_shadow(area: Area2D, pos: Vector2):
	print("we are definitely jumping to area " + str(area))
	shape_cast.clear_exceptions()
	# shape_cast.remove_exception(inhabited_shadow)
	inhabited_shadow = area
	# shape_cast.add_exception(inhabited_shadow)
	global_shadow_polygon = make_shadow_polygon_global(inhabited_shadow)
	jump_end_position = pos
	should_be_jumping = true


func clamp_to_current_shadow(val: Vector2) -> Vector2:
	# var polygon_node: CollisionPolygon2D = find(inhabited_shadow, CollisionPolygon2D)
	# var polygon: PackedVector2Array = polygon_node.polygon

	# var offset_polygon: PackedVector2Array = []
	# for p in polygon:
	# 	offset_polygon.append(polygon_node.to_global(p))

	if not Geometry2D.is_point_in_polygon(val, global_shadow_polygon):
		var closest_points = []
		for i in range(global_shadow_polygon.size()):
			closest_points.append(Geometry2D.get_closest_point_to_segment(val, global_shadow_polygon[i], global_shadow_polygon[wrapi(i + 1, 0, global_shadow_polygon.size())]))

		var min_dist = INF
		var closest_point_on_poly
		for p in closest_points:
			if val.distance_to(p) < min_dist:
				min_dist = val.distance_to(p)
				closest_point_on_poly = p

		return closest_point_on_poly
	else:
		return val

func is_inside_shadow(shadow: Area2D):
	return Geometry2D.is_point_in_polygon(position, global_shadow_polygon)


func make_shadow_polygon_global(shadow: Area2D) -> PackedVector2Array:
	var polygon_node: CollisionPolygon2D = Util.find(shadow, CollisionPolygon2D)
	var polygon: PackedVector2Array = polygon_node.polygon

	var offset_polygon: PackedVector2Array = []
	for p in polygon:
		offset_polygon.append(polygon_node.to_global(p))
	
	return offset_polygon
