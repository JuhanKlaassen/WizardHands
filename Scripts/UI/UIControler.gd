extends Control

class_name UIController

var _non_togglable_ui_elements: Array[Node] = []
var _togglable_ui_elements: Array[UIActionGroup] = []
var _pause_menu: Node
@export var _is_open: bool


func _ready() -> void:
	visible = true


	for child in get_children():
		if child.has_method("resume") and child.has_method("quit"):
			_pause_menu = child
			_pause_menu.visible = false
			continue

		if child.has_method("open") and child.has_method("close"):
			if child.input_event_action != null and child.input_event_action.action != "":
				var ui_action_group: UIActionGroup = null
				for group in _togglable_ui_elements:
					if group.action.action == child.input_event_action.action:
						ui_action_group = group
						break


				if ui_action_group != null:
					ui_action_group.elements.append(child)
				else:
					var new_group = UIActionGroup.new()
					new_group.action = child.input_event_action
					new_group.elements = []
					new_group.elements.append(child)
					_togglable_ui_elements.append(new_group)
			else:
				_non_togglable_ui_elements.append(child)


			if child.is_active_on_start:
				child.open()
			else:
				child.close()
		else:
			push_error("Child of UIController is not UIElement. Child: " + child.name + " Deleting...")
			child.queue_free()


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("cancel") and _is_open:
		hide_all()
		_is_open = false
		get_tree().root.set_input_as_handled()
	elif event.is_action_pressed("pause_toggle") and not _is_open and _pause_menu != null:
		_pause_menu.update()
		
		_pause_menu.visible = true
		get_tree().paused = true
		get_tree().root.set_input_as_handled()
		

	else:
		for ui_action_group in _togglable_ui_elements:
			if event.is_action_pressed(ui_action_group.action.action):
				if ui_action_group.is_open:
					hide_all()
					_is_open = false
				else:
					hide_all()
					ui_action_group.is_open = true
					for ui_element in ui_action_group.elements:
						ui_element.open()
					_is_open = true
				get_tree().root.set_input_as_handled()
				break


func hide_all() -> void:
	for ui_action_group in _togglable_ui_elements:
		ui_action_group.is_open = false
		for ui_element in ui_action_group.elements:
			ui_element.close()
