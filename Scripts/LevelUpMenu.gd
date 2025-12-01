extends CanvasLayer
class_name LevelUpMenu

signal option_selected(option_id)

func set_options(text1: String, text2: String, text3: String):
	$Panel/HBoxContainer/Option1.text = text1
	$Panel/HBoxContainer/Option2.text = text2
	$Panel/HBoxContainer/Option3.text = text3

func _ready():
	$Panel/HBoxContainer/Option1.pressed.connect(self._on_option1)
	$Panel/HBoxContainer/Option2.pressed.connect(self._on_option2)
	$Panel/HBoxContainer/Option3.pressed.connect(self._on_option3)

func _on_option1(): option_selected.emit(0)
func _on_option2(): option_selected.emit(1)
func _on_option3(): option_selected.emit(2)
