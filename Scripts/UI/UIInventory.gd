extends PanelContainer

class_name UIInventory

var _slot_scene: PackedScene = load("res://Prefabs/UI/UISlot.tscn")
var _slots_container: GridContainer
var _inventory_system: InventorySystem
var _slots: Array[UISlot] = []
@onready var _transfer_slot: UITransferSlot = get_node("/root/Game/UI/UITransferSlot")


func _ready() -> void:
	_slots_container = get_node("MarginContainer/ItemGrid")
	for child in _slots_container.get_children():
		child.visible = false
		child.queue_free()
		_slots.clear()
	reload()


func set_inventory_data(inventory_data: InventorySystem) -> void:
	if inventory_data != null:
		_inventory_system = inventory_data
		_inventory_system.on_inventory_changed.connect(reload)
		for i in range(_inventory_system.items.size()):
			var slot_scene: UISlot = _slot_scene.instantiate()
			slot_scene.name = "Slot " + str(i)
			_slots_container.add_child(slot_scene)
			_slots.append(slot_scene)
			slot_scene.on_slot_clicked.connect(handle_slot_click.bind(slot_scene))
	else:
		for child in _slots_container.get_children():
			child.visible = false
			child.queue_free()
			_slots.clear()
		_inventory_system = null

	reload()

func set_slot_scene(new_slot_scene: PackedScene) -> void:
	_slot_scene = new_slot_scene

func reload() -> void:
	if _inventory_system == null:
		return
	
	for i in range(_inventory_system.items.size()):
		if _inventory_system.items[i] != null:
			(get_slot(i) as UISlot).set_item(_inventory_system.items[i])
		

func get_slot(index: int) -> UISlot:
	return _slots[index]

func handle_slot_click(input_event: InputEvent, slot_scene: UISlot) -> void:
	if input_event is InputEventMouseButton:
		var mouse_button: InputEventMouseButton = input_event as InputEventMouseButton
		if mouse_button.pressed and mouse_button.button_index == MOUSE_BUTTON_LEFT:
			if _transfer_slot.is_transfering:
				if slot_scene.slot_type == _transfer_slot.transfered_data.item_type || slot_scene.slot_type == ItemData.ItemType.UNSET:
					if slot_scene.item.item_data == _transfer_slot.transfered_data:
						if slot_scene.item.amount + _transfer_slot.transfered_amount > slot_scene.item.item_data.max_stack:
							_transfer_slot.swap_with(slot_scene)
						else:
							_transfer_slot.transfer_to(slot_scene)
					elif slot_scene.item.item_data == null:
						_transfer_slot.transfer_to(slot_scene)
					else:
						_transfer_slot.swap_with(slot_scene)
			else:
				_transfer_slot.start_transfer(slot_scene)
			_inventory_system.on_inventory_changed.emit()
		elif mouse_button.pressed and mouse_button.button_index == MOUSE_BUTTON_RIGHT:
			if _transfer_slot.is_transfering:
				if slot_scene.slot_type == _transfer_slot.transfered_data.item_type || slot_scene.slot_type == ItemData.ItemType.UNSET:
					if slot_scene.item.item_data == _transfer_slot.transfered_data:
						if slot_scene.item.amount + _transfer_slot.transfered_amount >= slot_scene.item.item_data.max_stack:
							_transfer_slot.swap_with(slot_scene)
						else:
							_transfer_slot.transfer_to(slot_scene, 1)
						_inventory_system.on_inventory_changed.emit()
					elif slot_scene.item.item_data == null:
						_transfer_slot.transfer_to(slot_scene, 1)
						_inventory_system.on_inventory_changed.emit()
					else:
						_transfer_slot.swap_with(slot_scene)
						_inventory_system.on_inventory_changed.emit()
			else:
				var split_amount: int = 1
				if slot_scene.item.amount > 1:
					split_amount = int(floor(slot_scene.item.amount / 2.0))
				_transfer_slot.start_transfer(slot_scene, split_amount)
				_inventory_system.on_inventory_changed.emit()
