extends Node2D

var fragment_count: int
var enemy_count: int

# Called when the node enters the scene tree for the first time.
func _ready():
	var fragments := get_tree().root.find_children("ShadowFragment*", "", true, false)
	fragment_count = fragments.size()
	print("FRAGMENTS: %s" % fragment_count)
	Global.level_fragments = fragment_count
	var enemies := get_tree().root.find_children("Enemy*", "Enemy", true, false)
	enemy_count = enemies.size()
	Global.level_enemies = enemy_count
	Global.current_enemies = enemy_count

var scn_restart_level_overlay: PackedScene = preload("res://scenes/level/restart_level_overlay.tscn")
var restart_level_overlay: Node
var overlay_spawned: bool = false

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if Global.player_dead and not overlay_spawned:
		spawn_restart_level_overlay()
	
	if Input.is_action_just_pressed("reset"):
		Global.player_dead = false
		LevelManager.reset_level()

func spawn_restart_level_overlay():
	overlay_spawned = true
	restart_level_overlay = scn_restart_level_overlay.instantiate()
	add_child(restart_level_overlay)
