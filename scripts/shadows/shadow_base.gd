class_name ShadowBase extends Area2D

var USE_COLLISION_SHAPE: bool

var base_shadow_image: Image
var base_collision_poly: CollisionPolygon2D
var base_collision_shape: CollisionShape2D

@export var collision_polygon: CollisionPolygon2D
@export var collision_shape: CollisionShape2D
@export var sprite: Sprite2D

var corresponding_light: CustomLight

var num_shadow_sprites = 10

var mouse_inside: bool = false

var clicked_this_frame: bool = false

var outline_material: Material

var player: Player

func _ready():
	input_pickable = true
	set_collision_layer_value(1, true)

	input_event.connect(_on_input_event)

	mouse_entered.connect(_on_mouse_enter)
	mouse_exited.connect(_on_mouse_exit)

	sprite = $Sprite2D

func transform_sprite_image_to_shadow(light_position: Vector2) -> void:
	var direction = -(light_position - global_position).limit_length(2.0) # direction vector from the center of the object to the light, will use this vector to put the pixels of the image

	var final_image: Image

	if not USE_COLLISION_SHAPE:
		final_image = Image.create(200, 200, false, Image.FORMAT_RGBA8)
		var collision_shape_point_cloud: PackedVector2Array = []

		for i in range(2, num_shadow_sprites):
			var scaled_shadow_image: Image = Image.new()
			scaled_shadow_image.copy_from(base_shadow_image)
			if scaled_shadow_image.get_format() != Image.FORMAT_RGBA8:
				scaled_shadow_image.convert(Image.FORMAT_RGBA8)

			# scale image slightly
			var scale_amount: Vector2 = Vector2((1 + (0.5 * i / float(num_shadow_sprites))), (1 + (0.5 * i / float(num_shadow_sprites))))
			scaled_shadow_image.resize(base_shadow_image.get_width() * scale_amount.x, base_shadow_image.get_height() * scale_amount.y, Image.INTERPOLATE_NEAREST)

			# new image is 200 x 200 so we put the scaled location from the original in the center of the new one
			var scaled_location = Vector2(100 - scaled_shadow_image.get_width() / 2, 100 - scaled_shadow_image.get_height() / 2)


			var adjusted_direction = direction
			# if adjusted_direction.y < 0:
			# 	adjusted_direction.y *= 0.5

			
			var position_offset = 10.0 * adjusted_direction * i / float(num_shadow_sprites)
			scaled_location = scaled_location + position_offset

			position_offset.x -= 2
			position_offset.y += 2

			var scaled_collision_shape := scale_collision_shape(base_collision_poly, position_offset, scale_amount.x)

			collision_shape_point_cloud.append_array(scaled_collision_shape)


			# blit the scaled image to the final image
			var src_rect = Rect2i(Vector2i.ZERO, scaled_shadow_image.get_size())
			final_image.blit_rect_mask(scaled_shadow_image, scaled_shadow_image, src_rect, scaled_location)


		var new_polygon = ConvexPolygonShape2D.new()
		new_polygon.set_point_cloud(collision_shape_point_cloud)

		var clipped_polygons = Geometry2D.clip_polygons(new_polygon.points, base_collision_poly.polygon)

		collision_polygon.polygon = new_polygon.points
	else:
		final_image = Image.new()
		final_image.copy_from(base_shadow_image)

		var dir_to_light = global_position.direction_to(light_position)

		var shadow_offset = final_image.get_height() / 2

		var sprite_angle = dir_to_light.angle() + deg_to_rad(270)
		# sprite.rotation = sprite_angle
		sprite.offset.y = -shadow_offset
		# sprite.position.y = shadow_offset

		rotation = sprite_angle
		collision_shape.position.y = -shadow_offset
		position.y = shadow_offset

	# collision_polygon.polygon = clipped_polygons[0]


	sprite.texture = ImageTexture.create_from_image(final_image)


func scale_collision_shape(coll_poly: CollisionPolygon2D, position_offset: Vector2, scale_amount: float) -> PackedVector2Array:
	var points = coll_poly.polygon.duplicate()
	var ret = []
	for p in points:
		p *= scale_amount
		p += position_offset
		ret.append(p)
	
	return ret


func _on_input_event(viewport: Viewport, event: InputEvent, shape_idx: int):
	if event is InputEventMouseButton and event.is_pressed():
		if event.button_index == MOUSE_BUTTON_LEFT:
			clicked_this_frame = true

			player.clicked_on_shadow(self)
	else:
		clicked_this_frame = false



func _on_mouse_enter():
	# sprite.material = outline_material
	mouse_inside = true

func _on_mouse_exit():
	# sprite.material = null
	mouse_inside = false
