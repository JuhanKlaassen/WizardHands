extends PanelContainer

class_name UIWaveInfo

@export var input_event_action: InputEventAction
@export var is_active_on_start: bool = true

@onready var cooldown_label: Label = %CooldownLabel
@onready var enemies_label: Label = %EnemiesLabel

func set_cooldown(value: int) -> void:
	cooldown_label.text = "Next wave starts in: " + str(value)

func clear_cooldown() -> void:
	cooldown_label.text = ""

func set_enemies(value: int) -> void:
	enemies_label.text = "Enemies left: " + str(value)

func clear_enemies() -> void:
	enemies_label.text = ""

func close() -> void:
	visible = false


func open() -> void:
	visible = true
