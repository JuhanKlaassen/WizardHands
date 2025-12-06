extends CanvasLayer
class_name LevelUpMenu

signal option_selected(option_id)

func set_options(names: Array, values: Array, colors: Array):
	for i in range(3):
		var button = $Panel/HBoxContainer.get_child(i)
		button.text = "%s +%.2f" % [names[i], values[i]]
		button.modulate = colors[i]


func _ready():
	$Panel/HBoxContainer/Option1.pressed.connect(self._on_option1)
	$Panel/HBoxContainer/Option2.pressed.connect(self._on_option2)
	$Panel/HBoxContainer/Option3.pressed.connect(self._on_option3)

func _on_option1(): option_selected.emit(0)
func _on_option2(): option_selected.emit(1)
func _on_option3(): option_selected.emit(2)
