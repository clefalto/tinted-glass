extends Control

@export var player: Player

@onready var fragment_label: Label = $FragmentLabel
@onready var second_fragment_label: Label = $SecondFragmentLabel
@onready var door_label: Label = $DoorLabel
@onready var enemy_label: Label = $EnemyLabel
@export var monitored_enemy: Enemy

# Called when the node enters the scene tree for the first time.
func _ready():
	second_fragment_label.visible = false
	enemy_label.visible = false


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if Global.player_fragments > 0 and Global.current_enemies > 0 and not Global.collected_all_fragments:
		fragment_label.visible = false
		second_fragment_label.visible = true
	if Global.collected_all_fragments and Global.current_enemies > 0:
		if monitored_enemy.is_possessed:
			enemy_label.text = "jump to another shadow or wait to eliminate"
		else:
			second_fragment_label.visible = false
			enemy_label.visible = true
		enemy_label.global_position = monitored_enemy.global_position - Vector2(60, 25)

	if Global.current_enemies == 0 and Global.collected_all_fragments:
		second_fragment_label.visible = false
		enemy_label.visible = false
		door_label.text = "door is unlocked!"
