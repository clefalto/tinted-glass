extends Node2D

@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var shadow: Area2D = $Shadow

@export var player: Player

# @export var player: Player
var enemy_list: Array = []

var open_sound: AudioStream = preload("res://assets/sounds/door_open_3.wav")
# var close_sound: AudioStream = preload("res://assets/sounds/door_open_2.wav")

var opened: bool = false
var opening: bool = false

var player_exited: bool = false

var next_level_button: Button


# Called when the node enters the scene tree for the first time.
func _ready():
	shadow.disable()
	player = Global.get_player()
	shadow.player_entered.connect(check_close)
	# open()
	next_level_button = get_tree().root.find_child("NextLevelButton*", true, false)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if (not opening and not opened) and Global.level_fragments > 0 and Global.current_enemies == 0:
		open(true)
	elif (not opening and not opened) and Global.level_fragments == 0:
		open(false)

func check_close() -> void:
	if opened and not player_exited:
		if player.inhabited_shadow == shadow:
			player_exited = true
			player.current_health = player.max_health
			# player.visible = false
			shadow.input_pickable = false
			close()

func open(sound: bool) -> void:
	opening = true
	sprite.play("opening")
	if not sprite.animation_finished.is_connected(stay_open):
		sprite.animation_finished.connect(stay_open)
	if sound:
		Global.play_sound(open_sound)

func stay_open() -> void:
	# Global.play_sound(open_sound)
	sprite.animation_finished.disconnect(stay_open)
	sprite.play("opened")
	opened = true
	shadow.enable()

func mouse_entered() -> void:
	if opened and not player_exited:
		sprite.play("opened_outline")

func mouse_exited() -> void:
	if opened and not player_exited:
		sprite.play("opened")

func exit_level() -> void:
	sprite.animation_finished.disconnect(exit_level)
	next_level_button.reveal()
	# Global.play_sound(close_sound)
	print("we exiting level")

func close() -> void:
	# sprite.animation = "closing"
	sprite.play("closing")
	shadow.visible = false
	shadow.disable()
	if not sprite.animation_finished.is_connected(exit_level):
		sprite.animation_finished.connect(exit_level)
