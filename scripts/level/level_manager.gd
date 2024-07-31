extends Node

var current_level_idx: int
var current_level_scene: PackedScene

var on_main_menu: bool
var main_menu_scene: PackedScene = preload("res://scenes/level/levels/main_menu.tscn")
var end_screen_scene: PackedScene = preload("res://scenes/level/levels/end_screen.tscn")

var levels = [
	load("res://scenes/level/levels/level_1.tscn"),
	load("res://scenes/level/levels/level_2.tscn"),
	load("res://scenes/level/levels/level_3.tscn"),
	load("res://scenes/level/levels/level_4.tscn"),
	load("res://scenes/level/levels/level_5.tscn"),
	load("res://scenes/level/levels/level_6.tscn")
]

# Called when the node enters the scene tree for the first time.
func _ready():
	current_level_idx = 0
	current_level_scene = levels[current_level_idx]


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func go_to_next_level():
	current_level_idx += 1
	if current_level_idx >= levels.size():
		Global.on_level_reset()
		get_tree().change_scene_to_packed(end_screen_scene)
	else:
		Global.on_level_reset()
		current_level_scene = levels[current_level_idx]
		get_tree().change_scene_to_packed(current_level_scene)

func begin_game():
	Global.on_level_reset()
	current_level_scene = levels[0]
	current_level_idx = 0
	get_tree().change_scene_to_packed(levels[0])

func reset_level():
	get_tree().change_scene_to_packed(current_level_scene)
	Global.player_dead = false
	Global.on_level_reset()
	print("resetting")

func return_to_menu():
	Global.on_level_reset()
	get_tree().change_scene_to_packed(main_menu_scene)
	current_level_scene = levels[0]
	current_level_idx = 0
