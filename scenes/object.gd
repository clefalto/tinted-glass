extends Node2D

@onready var shadow = self.find_child("Shadow")
@export var light_manager: Node
@export var player: Player

# Called when the node enters the scene tree for the first time.
func _ready():
	shadow.player = player


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
