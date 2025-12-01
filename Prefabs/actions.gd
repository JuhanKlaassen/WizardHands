extends Node


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float):
	pass

func _input(event):
	#DEBUG
	# this is only run in editor, not in exported build
	#if OS.has_feature("editor"):

	if event.is_action_pressed("dbg_reload_game"):
		#get_tree().call_deferred("reload_current_scene")
		var items_to_delete: Array[Node] = get_tree().get_nodes_in_group("ground_items")
		print("Found %d ground items to delete." % items_to_delete.size())
		for item in items_to_delete:
			# Use queue_free() to safely remove the node from memory 
			# at the end of the current frame.
			item.queue_free()
		get_tree().reload_current_scene()
			
		if event.is_action_pressed("dbg_end_game"):
			get_tree().quit()
	else:
		pass


func _on_link_button_pressed() -> void:
	var items_to_delete: Array[Node] = get_tree().get_nodes_in_group("ground_items")
	print("Found %d ground items to delete." % items_to_delete.size())
	for item in items_to_delete:
		# Use queue_free() to safely remove the node from memory 
		# at the end of the current frame.
		item.queue_free()
	get_tree().reload_current_scene()
