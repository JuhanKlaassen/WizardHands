extends PanelContainer

class_name UIPauseMenu


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("pause_toggle"):
		resume()
		get_tree().root.set_input_as_handled()


func resume() -> void:
	visible = false
	get_tree().paused = false


func quit() -> void:
	get_tree().paused = false
	get_tree().change_scene_to_file("res://Scenes/MainMenu.tscn")