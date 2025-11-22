extends UIInventory

class_name UIPlayerHotbar

@onready var _player: Player = get_node("/root/Game/%Player")
@export var _input_event_action: InputEventAction
@export var _is_active_on_start: bool

var input_event_action: InputEventAction:
	get:
		return _input_event_action

var is_active_on_start: bool:
	get:
		return _is_active_on_start


func _ready() -> void:
	super._ready()
	set_inventory_data(_player.find_child("Hotbar") as InventorySystem)


func _input(event: InputEvent) -> void:
	if event.is_action_pressed("action1"):
		var item: Item = get_slot(0).item
		if item != null and item.item_data != null and item.item_data.has_method("action"):
			item.item_data.action(item, _player, _player.get_global_mouse_position())
	
	if event.is_action_pressed("action2"):
		var item: Item = get_slot(1).item
		if item != null and item.item_data != null and item.item_data.has_method("action"):
			item.item_data.action(item, _player, _player.get_global_mouse_position())


func close() -> void:
	visible = false


func open() -> void:
	visible = true
