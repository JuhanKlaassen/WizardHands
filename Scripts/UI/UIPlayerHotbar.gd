extends UIInventory

class_name UIPlayerHotbar

@onready var _player: Player = get_node("/root/Game/%Player")
@export var _input_event_action: InputEventAction
@export var _is_active_on_start: bool
@export var _hotbar_slot_scene: PackedScene = load("res://Prefabs/UI/UIHotbarSlot.tscn")

var input_event_action: InputEventAction:
	get:
		return _input_event_action

var is_active_on_start: bool:
	get:
		return _is_active_on_start


func _ready() -> void:
	super._ready()
	set_slot_scene(_hotbar_slot_scene)
	set_inventory_data(_player.find_child("Hotbar") as InventorySystem)
	_inventory_system.on_inventory_changed.emit()


func _input(event: InputEvent) -> void:
	if event.is_action_pressed("action1"):
		get_slot(0).on_slot_action_called.emit()
	
	if event.is_action_pressed("action2"):
		get_slot(1).on_slot_action_called.emit()


func close() -> void:
	visible = false


func open() -> void:
	visible = true
