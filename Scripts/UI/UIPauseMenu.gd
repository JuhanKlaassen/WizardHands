extends PanelContainer

class_name UIPauseMenu

@onready var player = get_node("/root/Game/Player")



func update():
	$VBoxContainer/level.text = 'LEVEL: '+ str(player.level)
	$VBoxContainer/dodge.text = 'DODGE: '+ str(player.dodge)
	$VBoxContainer/mana_reg.text = 'MANA REGEN: '+ str(player.mana_regen)
	$VBoxContainer/hp_reg.text = 'HP REGEN: '+ str(player.health_regen_per_second)
	$VBoxContainer/speed.text = 'HP REGEN: '+ str(player.speed)

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
