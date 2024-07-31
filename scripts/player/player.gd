class_name Player extends CharacterBody2D

@export var TEMPORARY_default_inhabited_shadow: Area2D
var inhabited_shadow: Area2D

var destination_position: Vector2
var interpolated_position: Vector2
var safe_interpolated_position: Vector2
var target_direction: Vector2

var inside_shadow_speed: float = 40.0

var global_shadow_polygon: PackedVector2Array

var jump_end_position: Node2D
var should_be_jumping: bool = false

@onready var shape_cast: ShapeCast2D = $ShapeCast2D
@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var eye_tracking_sprite: Sprite2D = $Sprite2D
@onready var audio_stream_player: AudioStreamPlayer2D = $AudioStreamPlayer2D
# @onready var fragment_particles: GPUParticles2D = $FragmentParticles
@onready var trail: Line2D = $Trail

@export var default_texture: Texture2D
@export var empowered_texture: Texture2D
@export var empowered_shadow_color: Color

@export var max_health: float = 100
@export var health_regen_rate: float = 5.0
@export var health_regen_delay: float = 0.5
var current_health: float = max_health
var time_since_last_damaged: float = 0.0

@export var fragment_pickup_particle_scene: PackedScene

@export var jump_sound: AudioStream = preload("res://assets/sounds/jump_to_shadow.wav")
@export var failed_jump_sound: AudioStream = preload("res://assets/sounds/failed_jump.wav")
@export var die_sound: AudioStream = preload("res://assets/sounds/player_die.wav")

var screen_bounds: Vector2 = Vector2(320, 180)

var fragment_counter: int = 0

var able_to_possess_enemies: bool = false
var possessing_enemy: bool = false
var possessed_enemy: Enemy

var disabled: bool = false

var in_between_shadows: bool = false


# Called when the node enters the scene tree for the first time.
func _ready():
	inhabited_shadow = TEMPORARY_default_inhabited_shadow
	global_shadow_polygon = make_shadow_polygon_global(inhabited_shadow)
	eye_tracking_sprite.texture = default_texture
	trail.shadow_color = Util.default_shadow_color
	

func _process(delta):
	# queue_redraw()
	pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta):
	if disabled: return
	
	# var beans = max_health / current_health
	# var desired_volume = 
	# if not is_nan(desired_volume):
	# 	audio_stream_player.volume_db = desired_volume
	# if current_health < max_health and not audio_stream_player.playing:
	# 	audio_stream_player.play()
	# elif current_health == max_health:
	# 	audio_stream_player.stop()

	if current_health == 0.0:
		print("players current health is 0, die to my hand")
		die()

	if time_since_last_damaged > health_regen_delay:
		current_health = clampf(current_health + health_regen_rate, 0.0, max_health)

	time_since_last_damaged += delta

	if in_between_shadows:
		return

	if not possessing_enemy and is_instance_valid(inhabited_shadow):
		var is_inside
		if inhabited_shadow.using_polygon:
			# update shadow polygon in case it moves
			global_shadow_polygon = make_shadow_polygon_global(inhabited_shadow)
			is_inside = is_inside_shadow_polygon(inhabited_shadow)
		else:
			is_inside = is_inside_shadow_shape(inhabited_shadow)

		# if is_inside_shadow_polygon(inhabited_shadow):
		if is_inside:
			if should_be_jumping:
				should_be_jumping = false
				jumped_to_shadow(inhabited_shadow) # callback calling back
				print("jumped to shadow")
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
			target_direction = position.direction_to(destination_position)

			if position.distance_to(destination_position) < 2.0:
				velocity = Vector2.ZERO
			else:
				velocity = target_direction * inside_shadow_speed

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
			destination_position = (inhabited_shadow.to_global(jump_end_position.position))
			# destination_position = to_local(jump_end_position.global_position)

			velocity = (destination_position - position).normalized() * 100.0

		else: # outside shadow and should not be outside shadow
			position = clamp_to_current_shadow(position)

			# push player back into shadow
			velocity = -velocity.normalized()
			
		move_and_slide()

	else:
		if is_instance_valid(possessed_enemy):
			self.position = possessed_enemy.global_position
		else:
			# possession ran out somehow (possessing flag is true but enemy instance is null)
			end_possessing_enemy()

	queue_redraw()


func damage(amount: float) -> void:
	if possessing_enemy:
		amount *= 0.5 # reduce damage taken when possessing
	current_health = clampf(current_health - amount, 0.0, max_health)
	var cam = get_parent().find_child("Camera*")
	if cam:
		cam.add_trauma(0.01)
	time_since_last_damaged = 0.0

func collect_fragment(fragment: ShadowFragment) -> void:
	fragment_counter += 1
	var emitter: GPUParticles2D = fragment_pickup_particle_scene.instantiate()
	add_child(emitter)
	emitter.emitting = true

func empower():
	able_to_possess_enemies = true
	eye_tracking_sprite.texture = empowered_texture
	trail.shadow_color = empowered_shadow_color

func die():
	print("die has been called ")
	Global.play_sound(die_sound)
	eye_tracking_sprite.visible = false
	sprite.visible = true
	sprite.play("die")
	self.disabled = true
	Global.player_dead = true

func _draw():
	# draw_circle(to_local(destination_position), 1, Color.GREEN)
	# draw_circle(to_local(interpolated_position), 1, Color.RED)
	# if is_instance_valid(jump_end_position):
	# 	draw_circle(to_local(jump_end_position.to_global(jump_end_position.position)), 1, Color.BLUE)
	# draw_circle(to_local(safe_interpolated_position), 2, Color.PINK)

	# draw_line(to_local(position), to_local(interpolated_position), Color.WHITE, 1.0)

	# draw_line(to_local(position), to_local(get_global_mouse_position()), Color.YELLOW, 1.0)

	# draw_circle(to_local(clamp_to_current_shadow(position)), 1, Color.PURPLE)

	# var to_localed_shadow_polygon = []
	# for p in global_shadow_polygon:
	# 	to_localed_shadow_polygon.push_back(to_local(p))

	# draw_colored_polygon(to_localed_shadow_polygon, Color.GREEN)

	# draw_circle((target_direction), 1,  Color.RED)

	# draw_circle(velocity, 1, Color.PURPLE)

	# if is_instance_valid(jump_end_position):
	# 	draw_circle(to_local(jump_end_position.global_position), 1, Color.BLUE)
	pass


func clicked_on_shadow(area: Area2D):
	if in_between_shadows:
		in_between_shadows = false

	if not able_to_possess_enemies and area.owned_by_enemy:
		# play a sound or something
		return
	
	if area == inhabited_shadow:
		return
	
	shape_cast.target_position = to_local(get_global_mouse_position())

	var jump_direction = position.direction_to(shape_cast.target_position)
	shape_cast.add_exception(inhabited_shadow)
	# shape_cast.add_exception(inhabited_shadow)
	shape_cast.force_shapecast_update()

	# var closest_shadow_point = Vector2.INF
	# var closest_wall_point = Vector2.INF

	# var shadow_point: Vector2

	# var hit_wall: bool = false
	# var hit_shadow_before_wall: bool = false

	# while shape_cast.get_collision_count() > 0:
	# 	var hit_wall_this_collision: bool = false
	# 	print("COLLISION COUNT: %s" % shape_cast.get_collision_count())
	# 	for i in range(shape_cast.get_collision_count()):
	# 		var collider = shape_cast.get_collider(i)
	# 		print("collider is %s, target area is %s, and collision_point is %v" % [collider, area, shape_cast.get_collision_point(i)])
	# 		if collider is Area2D and collider == area:
	# 			# var shadow_point = shape_cast.get_collision_point(i)
	# 			shadow_point = shape_cast.get_collision_point(i)
	# 			if not hit_wall:
	# 				hit_shadow_before_wall = true
	# 			# if position.distance_to(shadow_point) < position.distance_to(closest_shadow_point):
	# 			# 	closest_shadow_point = shadow_point
	# 			# 	print("set shadow point to %s" % shadow_point)
	# 		if collider is StaticBody2D or collider is TileMap:
	# 			# wall_point = shape_cast.get_collision_point(i)
	# 			# if position.distance_to(wall_point) < position.distance_to(closest_wall_point):
	# 			# 	closest_wall_point = wall_point
	# 			# 	print("set wall point to %s" % wall_point)
	# 			hit_wall_this_collision = true
			
	# 		if hit_wall_this_collision and hit_shadow_before_wall:
	# 			hit_wall = true
	# 		if not (collider is TileMap): # avoid crash LOL
	# 			shape_cast.add_exception(collider)

	# 	shape_cast.force_shapecast_update()
	
	var hit_tilemap = false
	var hit_wall = false
	var shadow_collision_point: Vector2
	
	var wall_collision_point: Vector2
	var tilemap_collision_point: Vector2

	while shape_cast.get_collision_count() > 0 and not hit_tilemap:
		for i in range(shape_cast.get_collision_count()):
			var collider = shape_cast.get_collider(i)
			if collider is Area2D and collider == area and not hit_wall:
				shadow_collision_point = shape_cast.get_collision_point(i)
			elif collider is StaticBody2D:
				hit_wall = true
				wall_collision_point = shape_cast.get_collision_point(i)
			elif collider is TileMap:
				hit_tilemap = true
				wall_collision_point = shape_cast.get_collision_point(i)
			

			if not (hit_tilemap):
				shape_cast.add_exception(collider)

		
		
		shape_cast.force_shapecast_update()
	
	shape_cast.clear_exceptions()

	var direction_to_shadow = position.direction_to(shadow_collision_point)
	var direction_to_wall = position.direction_to(wall_collision_point)
	var shadow_dot = jump_direction.dot(direction_to_shadow)
	var wall_dot = jump_direction.dot(direction_to_wall)
	if position.distance_to(shadow_collision_point) < position.distance_to(wall_collision_point):
		hit_wall = false

	if not hit_wall and shadow_collision_point:
		# do it again just in case the collision point was misleading

		shape_cast.target_position = shape_cast.to_local(shadow_collision_point)

		# var jump_direction = position.direction_to(shape_cast.target_position)
		shape_cast.add_exception(inhabited_shadow)
		# shape_cast.add_exception(inhabited_shadow)
		shape_cast.force_shapecast_update()

		var again_hit_tilemap = false
		var again_hit_wall = false
		var again_shadow_point: Vector2 = Vector2.ZERO

		while shape_cast.get_collision_count() > 0 and not again_hit_tilemap:
			for i in range(shape_cast.get_collision_count()):
				var collider = shape_cast.get_collider(i)

				if collider is StaticBody2D:
					again_hit_wall = true
				elif collider is TileMap:
					again_hit_tilemap = true
				

				if not (again_hit_tilemap):
					shape_cast.add_exception(collider)

			
			shape_cast.force_shapecast_update()

		if not again_hit_wall:
			jump_to_shadow(area, shadow_collision_point)
		else:
			on_fail_to_jump_to_shadow(shape_cast.target_position)
	else:
		on_fail_to_jump_to_shadow(shape_cast.target_position)


	# if not wall_point and shadow_point:
	# 	jump_to_shadow(area, shadow_point)
	# if wall_point and shadow_point:
	# 	if position.distance_to(wall_point) > position.distance_to(shadow_point):
	# 		jump_to_shadow(area, shadow_point)
	
	# if position.distance_to(closest_wall_point) > position.distance_to(closest_shadow_point):
	# 	jump_to_shadow(area, closest_shadow_point)

	# if not hit_wall: 
	# 	jump_to_shadow(area, shadow_point)
	
	

	# shape_cast.add_exception(inhabited_shadow)
	# shape_cast.force_shapecast_update()
	# var collider = shape_cast.get_collider(0)
	# if not collider:
	# 	jump_to_shadow(area)

func on_fail_to_jump_to_shadow(fail_pos: Vector2):
	var failed_jump_indicator: Line2D = $FailedJumpIndicator
	Global.play_sound(failed_jump_sound)
	failed_jump_indicator.visible = true
	failed_jump_indicator.set_point_position(1, fail_pos)
	var t = create_tween()
	failed_jump_indicator.default_color = Color(1.0, 0.48, 0.48, 0.5)
	t.tween_property(failed_jump_indicator, "default_color", Color(1.0, 0.48, 0.48, 0.0), 0.3)


func jump_to_shadow(shadow: Area2D, pos: Vector2):
	print("we are definitely jumping to area " + str(shadow))
	shape_cast.clear_exceptions()
	# shape_cast.remove_exception(inhabited_shadow)
	inhabited_shadow = shadow
	if shadow.using_polygon:
		global_shadow_polygon = make_shadow_polygon_global(inhabited_shadow)

	# shape_cast.add_exception(inhabited_shadow)

	if possessing_enemy:
		end_possessing_enemy()

	# create a node as a child of the shadow, so that if the shadow transforms, the jump position transforms with it.
	if is_instance_valid(jump_end_position):
		jump_end_position.free()
	jump_end_position = Node2D.new()
	shadow.add_child(jump_end_position)
	jump_end_position.position = shadow.to_local((pos))
	# jump_end_position = pos
	should_be_jumping = true

	Global.play_sound(jump_sound, true)

# callback called when we finished jumping to the shadaur
func jumped_to_shadow(shadow: Area2D):
	if shadow.owned_by_enemy:
		shadow.possess_as_enemy()
	if shadow is ExitDoorShadow:
		disabled = true
		visible = false
		shadow.player_entered.emit()

func clamp_to_current_shadow(val: Vector2) -> Vector2:
	# var polygon_node: CollisionPolygon2D = find(inhabited_shadow, CollisionPolygon2D)
	# var polygon: PackedVector2Array = polygon_node.polygon

	# var offset_polygon: PackedVector2Array = []
	# for p in polygon:
	# 	offset_polygon.append(polygon_node.to_global(p))

	var using_polygon: bool
	
	if inhabited_shadow.using_polygon:
		using_polygon = true
	else:
		using_polygon = false


	if using_polygon:
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
	else:
		val = inhabited_shadow.collision_shape.to_local(val)
		var closest_point_on_shape: Vector2 = Vector2.ZERO
		var shape = inhabited_shadow.collision_shape.shape
		var rect = shape.get_rect()
		if not rect.has_point(val):
			var origin = rect.position - rect.size/2
			closest_point_on_shape.x = clamp(val.x, origin.x, rect.end.x)
			closest_point_on_shape.y = clamp(val.y, origin.y, rect.end.y)
			return inhabited_shadow.collision_shape.to_global(closest_point_on_shape)
		else:
			return inhabited_shadow.collision_shape.to_global(val)
		


func is_inside_shadow_polygon(shadow: Area2D, scale: bool = false):
	if not scale:
		return Geometry2D.is_point_in_polygon(position, global_shadow_polygon)
	else: return Geometry2D.is_point_in_polygon(position, scale_polygon_by(global_shadow_polygon, 1.1))

func scale_polygon_by(polygon: PackedVector2Array, amount: float):
	var new_poly = []
	for point in polygon:
		new_poly.push_back(point * amount)
	return new_poly

func is_inside_shadow_shape(shadow: Area2D):
	print("called isinsideshadowshape")
	var cs2d: CollisionShape2D = shadow.collision_shape
	print("returning %s" % cs2d.shape.get_rect().has_point(position))
	return cs2d.shape.get_rect().has_point(cs2d.to_local(position))

func make_shadow_polygon_global(shadow: Area2D) -> PackedVector2Array:
	var polygon_node: CollisionPolygon2D = shadow.collision_polygon
	var polygon: PackedVector2Array = polygon_node.polygon

	var offset_polygon: PackedVector2Array = []
	for p in polygon:
		offset_polygon.append(polygon_node.to_global(p))
	
	return offset_polygon


func begin_possessing_enemy(enemy: Enemy):
	possessing_enemy = true
	possessed_enemy = enemy
	self.visible = false

func end_possessing_enemy():
	possessing_enemy = false
	self.visible = true
	if is_instance_valid(possessed_enemy):
		possessed_enemy.die()
	# probably want to jump to the nearest shadow if the inhabited shadow is still the enemy
	if not inhabited_shadow: # were inhabiting the enemy shadow, enemy died, shadow was freed
		# slow down time to allow the player to jump to a new shadow, if not they DIE
		in_between_shadows = true
