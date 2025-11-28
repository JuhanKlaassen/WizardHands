extends UIInventory

class_name UIPlayerInventory

@export var _input_event_action: InputEventAction
@export var _is_active_on_start: bool

@onready var _player: Player = get_node("/root/Game/%Player")

var input_event_action: InputEventAction:
	get:
		return _input_event_action

var is_active_on_start: bool:
	get:
		return _is_active_on_start


func _ready() -> void:
	super._ready()
	set_inventory_data(get_node("/root/Game/%Player/%Inventory"))
	for slot in _slots:
		slot.on_slot_clicked.disconnect(handle_slot_click.bind(slot))
		slot.on_slot_clicked.connect(func(event: InputEvent) -> void:
			if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.shift_pressed:
				if slot.item != null and slot.item.item_data != null and slot.item.item_data.item_type == ItemData.ItemType.WAND:
					slot.swap_with(_player._ui_hotbar.get_slot(0))
					_player._hotbar.on_inventory_changed.emit()
					return
			elif event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_RIGHT and event.shift_pressed:
				if slot.item != null and slot.item.item_data != null and slot.item.item_data.item_type == ItemData.ItemType.WAND:
					slot.swap_with(_player._ui_hotbar.get_slot(1))
					_player._hotbar.on_inventory_changed.emit()
					return

			handle_slot_click(event, slot)
		)


func close() -> void:
	visible = false


func open() -> void:
	visible = true
