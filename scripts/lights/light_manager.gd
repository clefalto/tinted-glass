extends Node

var lights_in_scene: Array[CustomLight]

# Called when the node enters the scene tree for the first time.
func _ready():
	lights_in_scene = get_all_lights_in_children(get_tree().root)
	# print("LIGHTS IN SCENE: " + str(lights_in_scene))
	get_tree().node_added.connect(_on_scene_tree_node_added)
	get_tree().node_removed.connect(_on_scene_tree_node_removed)

func _on_scene_tree_node_added(node: Node):
	if node is CustomLight:
		lights_in_scene.append(node)

func _on_scene_tree_node_removed(node: Node):
	if node is CustomLight:
		var idx = lights_in_scene.find(node)
		lights_in_scene.remove_at(idx)


func get_all_lights_in_children(node: Node) -> Array[CustomLight]:
	var list: Array[CustomLight] = []
	if node is CustomLight:
		list.append(node)
		return list
	if node.get_child_count() == 0:
		return list
	var children = node.get_children()
	for c in children:
		list.append_array(get_all_lights_in_children(c))
	return list
		
