extends Node

@onready var default_shadow_color: Color = Color(0.157, 0.031, 0.176, 1.0)

func find(parent, type):
	for child in parent.get_children():
		if is_instance_of(child, type):
			return child
		var grandchild = find(child, type)
		if grandchild != null:
			return grandchild
	return null


