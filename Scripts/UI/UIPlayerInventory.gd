extends UIInventory

class_name UIPlayerInventory

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
	set_inventory_data(get_node("/root/Game/%Player/%Inventory"))


func close() -> void:
	visible = false


func open() -> void:
	visible = true
