extends PanelContainer

class_name UIAltar

@export var input_event_action: InputEventAction
@export var is_active_on_start: bool

@onready var wand_ui_inventory: UIInventory = %WandInventory
@onready var modifier_ui_inventory: UIInventory = %ModifierInventory
@onready var stats_label: Label = %StatsLabel

func _ready() -> void:
	pass


func close() -> void:
	visible = false


func open() -> void:
	visible = true
