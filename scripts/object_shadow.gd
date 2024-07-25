class_name ObjectShadow extends Node2D

@export var light_manager: Node
@export var shadow_creator_sprite: Sprite2D
@export var num_shadow_sprites: int = 10

@export var dynamic_shadow_scene: PackedScene

@export var player: Player

@export var shadow_creator_collision_shape: CollisionShape2D
@export var shadow_creator_collision_poly: CollisionPolygon2D

@export var shadow_outline_material: Material

var use_polygon: bool

signal clicked_on_area(area: Area2D)

# @onready var shadow_sprite: Sprite2D = $Sprite2D

var light_sprite_dict: Dictionary = {} # customlight sprite2d
var light_shape_dict: Dictionary = {} # customlight collisionpolygon2d

var light_area_dict: Dictionary = {}
var area_input_dict: Dictionary = {}

var light_shadow_dict: Dictionary = {} # customlight objectshadow

@export_color_no_alpha var shadow_color: Color = Color(0.157, 0.031, 0.176)
var shadow_image_base: Image

# Called when the node enters the scene tree for the first time.
func _ready():
	var original_image: Image = shadow_creator_sprite.texture.get_image()
	shadow_image_base = Image.new()
	shadow_image_base.copy_from(original_image)
	for y in original_image.get_height():
		for x in original_image.get_width():
			if original_image.get_pixel(x, y).a > 0:
				shadow_image_base.set_pixel(x, y, shadow_color)
	

	use_polygon = true if (shadow_creator_collision_shape == null and shadow_creator_collision_poly != null) else false

	if not light_manager:
		light_manager = get_tree().root.find_child("LightManager", true, false)
		if not light_manager:
			print("object %s could not find a light manager oopsies! no good" % self.get_parent())

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if light_manager:
		for light in light_manager.lights_in_scene:
			var light_location = light.global_position

			if light_shadow_dict.has(light):
				if use_polygon:
					light_shadow_dict[light].transform_sprite_image_to_shadow(light_location)

			else:
				var dynamic_shadow := dynamic_shadow_scene.instantiate()
				dynamic_shadow.USE_COLLISION_SHAPE = false

				# var spr = Sprite2D.new()
				# var area = Area2D.new()

				# dynamic_shadow.area = area
				# dynamic_shadow.sprite = spr
				# dynamic_shadow.add_child(area)
				dynamic_shadow.outline_material = shadow_outline_material
				dynamic_shadow.player = player
				# dynamic_shadow.use_parent_material = true
				# spr.use_parent_material = true

				if use_polygon:
					var cs2d = CollisionPolygon2D.new()
					dynamic_shadow.area.add_child(cs2d)
					dynamic_shadow.collision_polygon = cs2d

					# dynamic_shadow.add_child(spr)

					dynamic_shadow.base_shadow_image = shadow_image_base
					dynamic_shadow.base_collision_poly = shadow_creator_collision_poly
					
					light_shadow_dict[light] = dynamic_shadow

					add_child(dynamic_shadow)

					dynamic_shadow.transform_sprite_image_to_shadow(light_location)

	for light in light_shadow_dict:
		var shadow_obj = light_shadow_dict[light]

		if shadow_obj.clicked_this_frame:
			print("CLICK! " + str(shadow_obj))
			

	# shadow_sprite.texture = transform_sprite_pixels_to_shadow_flat()
	# shadow_sprite.position = position - Vector2(direction.x * 10, direction.y * 10 - 3)
	# shadow_sprite.rotation = direction.angle() + deg_to_rad(90)

	# queue_redraw()


func transform_sprite_pixels_to_shadow(light_position: Vector2, magnitude: float) -> Texture2D:
	# for every pixel in the original texture, transform it according to where the light is coming from, with the magnitude being the distance it goes
	# magnitude should be integers as we're using pixels
	# basically transforming every pixel in the original texture to another location in the color of shadows


	# might need to convert single pixels on the texture to multiple pixels on the shadow texture, and vice versa
	
	var original_texture: Texture2D = shadow_creator_sprite.texture
	var original_image: Image = original_texture.get_image()
	var direction = -(light_position - global_position).limit_length(2.0) # direction vector from the center of the object to the light, will use this vector to put the pixels of the image

	var shadow_image: Image = Image.create(200, 200, false, Image.FORMAT_RGBA8)
	

	for y in original_image.get_height():
		for x in original_image.get_width():
			if original_image.get_pixel(x, y).a > 0:
				# var rotated_location =  Vector2(x, y).rotated(direction.angle() + deg_to_rad(90))
				var scaled_location = Vector2(x, y) + Vector2(100 - original_image.get_width() / 2, 100 - original_image.get_height() / 2)
				# var scaled_location = Vector2(x, y)
				for i in range(2, num_shadow_sprites):
					shadow_image.set_pixel(scaled_location.x + direction.x * magnitude * i/num_shadow_sprites, scaled_location.y + direction.y * magnitude * i/num_shadow_sprites, shadow_color)
				# shadow_image.set_pixel(scaled_location.x + direction.x * direction.length_squared() * 10, scaled_location.y + direction.y * direction.length_squared() * 10, shadow_color)
				# shadow_image.set_pixel(scaled_location.x, scaled_location.y, shadow_color)

	return ImageTexture.create_from_image(shadow_image)

func transform_sprite_image_to_shadow(light_position: Vector2, target_collision_shape: ConvexPolygonShape2D) -> Texture2D:
	var direction = -(light_position - global_position).limit_length(2.0) # direction vector from the center of the object to the light, will use this vector to put the pixels of the image

	var final_image: Image = Image.create(200, 200, false, Image.FORMAT_RGBA8)

	var collision_shape_point_cloud: PackedVector2Array = []

	for i in range(2, num_shadow_sprites):
		var scaled_shadow_image: Image = Image.new()
		scaled_shadow_image.copy_from(shadow_image_base)

		# scale image slightly
		var scale_amount: Vector2 = Vector2((1 + (0.5 * i / float(num_shadow_sprites))), (1 + (0.5 * i / float(num_shadow_sprites))))
		scaled_shadow_image.resize(shadow_image_base.get_width() * scale_amount.x, shadow_image_base.get_height() * scale_amount.y, Image.INTERPOLATE_NEAREST)

		# new image is 200 x 200 so we put the scaled location from the original in the center of the new one
		var scaled_location = Vector2(100 - scaled_shadow_image.get_width() / 2, 100 - scaled_shadow_image.get_height() / 2)

		# print("pre move scaled location: " + str(scaled_location))

		# move along direction vector, the vertical y direction should be slightly less powerful though, as the game is isometric
		var adjusted_direction = direction
		# var dot = adjusted_direction.dot(Vector2.UP)

		if adjusted_direction.y < 0:
			adjusted_direction.y *= 0.5

		
		var position_offset = 10.0 * adjusted_direction * i / float(num_shadow_sprites)
		scaled_location = scaled_location + position_offset

		position_offset.x -= 2
		position_offset.y += 2

		var scaled_collision_shape := scale_collision_shape(shadow_creator_collision_poly, position_offset, scale_amount.x)
		# print(scaled_collision_shape)

		collision_shape_point_cloud.append_array(scaled_collision_shape)

		# print("post move scaled location: " + str(scaled_location))

		# blit the scaled image to the final image
		var src_rect = Rect2i(Vector2i.ZERO, scaled_shadow_image.get_size())
		# scaled_shadow_image.save_png("res://debug/shadow_image_test/scaled" + str(i) + ".png")
		final_image.blit_rect_mask(scaled_shadow_image, scaled_shadow_image, src_rect, scaled_location)
		# final_image.save_png("res://debug/shadow_image_test/final" + str(i) + ".png")

	# final_image.save_png("res://debug/shadow_image_test/finalfinal.png")

	target_collision_shape.set_point_cloud(collision_shape_point_cloud)

	return ImageTexture.create_from_image(final_image)
	
func scale_collision_shape(collision_polygon: CollisionPolygon2D, position_offset: Vector2, scale_amount: float) -> PackedVector2Array:
	var points = collision_polygon.polygon.duplicate()
	var ret = []
	for p in points:
		p *= scale_amount
		p += position_offset
		ret.append(p)
	
	return ret

# use with rotation of the sprite2d
func transform_sprite_pixels_to_shadow_flat() -> Texture2D:
	var original_texture: Texture2D = shadow_creator_sprite.texture
	var original_image: Image = original_texture.get_image()
	var shadow_image: Image = Image.new()
	shadow_image.copy_from(original_image)
	for y in original_image.get_height():
		for x in original_image.get_width():
			if original_image.get_pixel(x, y).a > 0:
				shadow_image.set_pixel(x, y, shadow_color)

	return ImageTexture.create_from_image(shadow_image)


# func construct_new_shadow_polygon(light_location: Vector2, amount: float) -> PackedVector2Array:
# 	var untransformed_poly = shadow_creator.polygon
# 	var shadow_poly = []
# 	for i in range(untransformed_poly.size()):
# 		# shadow_poly.append(untransformed_poly[i])
# 		shadow_poly.append(untransformed_poly[i] + amount * (untransformed_poly[i] - light_location))

# 	return shadow_poly

# func _draw():
	# draw_line(self.position, get_global_mouse_position(), Color.GREEN)
	# draw_colored_polygon(shadow_polygon.polygon, shadow_color)
	# draw_texture(transform_sprite_pixels_to_shadow(Vector2.ONE.normalized(), 1.0), position)
