class_name EnemyShadow extends Node2D

@export var light_manager: Node
@export var shadow_creator_sprite: AnimatedSprite2D
@export var num_shadow_sprites: int = 10

@export var dynamic_shadow_scene: PackedScene

@export var player: Player

@export var shadow_creator_collision_shape: CollisionShape2D

@export var shadow_outline_material: Material

@export_color_no_alpha var shadow_color: Color = Color(0.157, 0.031, 0.176)
var shadow_image

@export var owned_by_enemy: bool = true

var light_shadow_dict: Dictionary = {} # customlight - dynamicshadow dictionary

signal possessed(shadow: Area2D)

# Called when the node enters the scene tree for the first time.
func _ready():
	var current_texture = get_texture_from_sprite(shadow_creator_sprite)

	var original_image: Image = current_texture.get_image()
	shadow_image = convert_image_to_shadow(original_image)

	if not player:
		player = Global.get_player()
	
	if not light_manager:
		light_manager = get_tree().root.find_child("LightManager", true, false)
		if not light_manager:
			print("object %s could not find a light manager oopsies! no good" % self.get_parent())


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if light_manager:
		for light in light_manager.lights_in_scene:
			var light_location = light.global_position

			# check if this light has already created a dynamic shadow
			if light_shadow_dict.has(light):
				# get current sprite texture and set it in the shadow, so that it changes according to the animation frame!
				# could cache this later to make it run slightly faster if things go bad
				var current_texture = get_texture_from_sprite(shadow_creator_sprite)
				var current_shadow_image = convert_image_to_shadow(current_texture.get_image())
				light_shadow_dict[light].base_shadow_image = current_shadow_image
				light_shadow_dict[light].transform_sprite_image_to_shadow(light_location)
			else:
				# instantiate a dynamic shadow for this light
				var dynamic_shadow := dynamic_shadow_scene.instantiate()
				dynamic_shadow.using_polygon = false

				# var spr = Sprite2D.new()
				# var area = Area2D.new()

				# dynamic_shadow.area = area
				# dynamic_shadow.sprite = spr
				# dynamic_shadow.add_child(area)
				dynamic_shadow.outline_material = shadow_outline_material
				dynamic_shadow.player = player
				# dynamic_shadow.use_parent_material = true
				# spr.use_parent_material = true

				var cs2d = shadow_creator_collision_shape.duplicate()
				dynamic_shadow.add_child(cs2d)
				dynamic_shadow.collision_shape = cs2d

				dynamic_shadow.owned_by_enemy = true
				dynamic_shadow.possessed.connect(on_shadow_possessed)

				# dynamic_shadow.add_child(spr)

				var current_texture = get_texture_from_sprite(shadow_creator_sprite)
				# print("CURRENT TEXTURE: %s" % current_texture)
				var current_shadow_image = convert_image_to_shadow(current_texture.get_image())
				# print("CURRENT SHADOW IMAGE: %s" % current_shadow_image)

				dynamic_shadow.base_shadow_image = current_shadow_image
				dynamic_shadow.base_collision_shape = shadow_creator_collision_shape
				
				light_shadow_dict[light] = dynamic_shadow

				add_child(dynamic_shadow)

				dynamic_shadow.transform_sprite_image_to_shadow(light_location)

	for light in light_shadow_dict:
		var shadow_obj = light_shadow_dict[light]

		if shadow_obj.clicked_this_frame:
			print("CLICK! " + str(shadow_obj))


func convert_image_to_shadow(original_image: Image) -> Image:
	var shadow_image_base = Image.new()
	shadow_image_base.copy_from(original_image)
	for y in original_image.get_height():
		for x in original_image.get_width():
			if original_image.get_pixel(x, y).a > 0:
				shadow_image_base.set_pixel(x, y, shadow_color)
	
	return shadow_image_base

func get_texture_from_sprite(spr: AnimatedSprite2D) -> Texture2D:
	var frame_index: int = spr.frame
	var animation_name: String = spr.animation
	var sprite_frames: SpriteFrames = spr.sprite_frames
	var current_texture: Texture2D = sprite_frames.get_frame_texture(animation_name, frame_index)
	return current_texture

func on_shadow_possessed(shadow: Area2D):
	print("enemyshadiow possess")
	possessed.emit(shadow)
