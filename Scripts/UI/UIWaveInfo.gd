extends PanelContainer

class_name UIWaveInfo

signal start_wave

@export var input_event_action: InputEventAction
@export var is_active_on_start: bool = true

@onready var cooldown_label: Label = %CooldownLabel
@onready var enemies_label: Label = %EnemiesLabel
@onready var start_wave_button: Button = %StartNextWaveButton

func _ready() -> void:
	start_wave_button.pressed.connect(
		func():
			start_wave.emit()
	)

func set_cooldown(value: int) -> void:
	cooldown_label.text = "Next wave starts in: " + str(value)

func clear_cooldown() -> void:
	cooldown_label.text = ""

func set_enemies(value: int) -> void:
	enemies_label.text = "Enemies left: " + str(value)

func clear_enemies() -> void:
	enemies_label.text = ""

func show_start_wave_button() -> void:
	if start_wave_button == null:
		return
	start_wave_button.visible = true

func hide_start_wave_button() -> void:
	if start_wave_button == null:
		return
	start_wave_button.visible = false

func close() -> void:
	visible = false

func open() -> void:
	visible = true
