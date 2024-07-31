extends Control

@export var monitored_start_shadow: StaticShadow
@export var monitored_exit_door_tmap: TileMap
var monitored_exit_door_shadow: Area2D
@export var player: Player

@onready var jump_label: Label = $JumpLabel
@onready var door_label: Label = $DoorLabel

# Called when the node enters the scene tree for the first time.
func _ready():
	jump_label.visible = true
	door_label.visible = false

	monitored_exit_door_shadow = monitored_exit_door_tmap.find_child("ExitDoor*")


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if player.inhabited_shadow != monitored_start_shadow and player.inhabited_shadow != monitored_exit_door_shadow:
		jump_label.visible = false
		door_label.visible = true
	elif player.inhabited_shadow == monitored_exit_door_shadow:
		door_label.visible = false
