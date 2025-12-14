extends PanelContainer

class_name UIPauseMenu

@onready var player = get_node("/root/Game/Player")

func _ready():
	var mode = DisplayServer.window_get_mode()
	$Options/CenterContainer/VBoxContainer/Fullscreen.button_pressed = (
		mode == DisplayServer.WINDOW_MODE_FULLSCREEN
		or mode == DisplayServer.WINDOW_MODE_EXCLUSIVE_FULLSCREEN
	)


func update():
	$VBoxContainer/level.text = 'LEVEL: '+ str(player.level)
	$VBoxContainer/dodge.text = 'DODGE: '+ str(int(player.dodge))+'%'
	$VBoxContainer/mana_reg.text = 'MANA PER SEC: '+ str(player.mana_regen)
	$VBoxContainer/hp_reg.text = 'HP PER SEC: '+ str(int(player.health_regen_per_second))
	$VBoxContainer/speed.text = 'SPEED: '+ str(int(player.speed))
	$VBoxContainer/xp_gain.text = 'XP GAIN: X'+str(player.more_xp)
	$VBoxContainer/gold_gain.text = 'GOLD GAIN: X'+str(player.more_gold)
	$VBoxContainer/luck.text = 'LUCK: '+str(int(player.luck))

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("pause_toggle"):
		$Paused.show()
		$VBoxContainer.show()
		$Options.hide()
		resume()
		get_tree().root.set_input_as_handled()

func resume() -> void:
	visible = false
	get_tree().paused = false


func quit() -> void:
	get_tree().paused = false
	get_tree().change_scene_to_file("res://Scenes/MainMenu.tscn")


func _on_options_pressed() -> void:
	$Paused.hide()
	$VBoxContainer.hide()
	$Options.show()



func _on_volume_value_changed(value: float) -> void:
	AudioServer.set_bus_volume_db(
		0,
		linear_to_db(value)
	)



func _on_back_pressed() -> void:
	$Paused.show()
	$VBoxContainer.show()
	$Options.hide()


func _on_resolutions_item_selected(index: int) -> void:
	if DisplayServer.window_get_mode() != DisplayServer.WINDOW_MODE_WINDOWED:
		return
	
	match index:
		0:
			DisplayServer.window_set_size(Vector2i(1920, 1080))
		1:
			DisplayServer.window_set_size(Vector2i(1600, 900))
		2:
			DisplayServer.window_set_size(Vector2i(1280, 720))


func _on_fullscreen_toggled(pressed: bool) -> void:
	if pressed:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_EXCLUSIVE_FULLSCREEN)
	else:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
