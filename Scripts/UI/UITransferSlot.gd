extends PanelContainer

class_name UITransferSlot

var _icon: TextureRect
var _amount_label: Label
var _transfered_data: ItemData
var _transfered_amount: int

var is_transfering: bool:
	get:
		return _transfered_data != null

var transfered_data: ItemData:
	get:
		return _transfered_data

var transfered_amount: int:
	get:
		return _transfered_amount


func _ready() -> void:
	_icon = get_node("MarginContainer/TextureRect")
	_amount_label = get_node("AmountLabel")


func _process(_delta: float) -> void:
	if is_transfering:
		position = get_global_mouse_position()


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("cancel"):
		#abort_transfer()
		get_tree().root.set_input_as_handled()


func start_transfer(from_slot: UISlot, amount: int = -1) -> void:
	if amount == -1:
		amount = from_slot.item.amount

	if from_slot.item.item_data == null:
		return
	
	_transfered_data = from_slot.item.item_data
	_transfered_amount = amount
	reload_visual()
	
	from_slot.item.remove(amount)
	from_slot.reload()


func transfer_to(to_slot: UISlot, amount: int = -1) -> void:
	if amount == -1:
		amount = _transfered_amount
	
	if to_slot.item.item_data != null and to_slot.item.item_data != _transfered_data:
		push_error("UITransferSlot.transfer_to | Can't transfer items of different types")
		return
	
	if to_slot.item.item_data == null:
		to_slot.item.set_item_data(_transfered_data, amount)
	else:
		if to_slot.item.amount + amount > to_slot.item.item_data.max_stack:
			push_error("UITransferSlot.transfer_to | Can't transfer items, target slot will be overflown")
			return
		
		to_slot.item.add(amount)
	
	if _transfered_amount - amount > 0:
		_transfered_amount -= amount
		reload_visual()
	else:
		clear()


func swap_with(slot: UISlot) -> void:
	if slot.item.item_data == null:
		push_error("UITransferSlot.swap_with | Can't swap with empty slot")
		return
	
	var temp_data: ItemData = slot.item.item_data
	var temp_amount: int = slot.item.amount
	
	slot.item.set_item_data(_transfered_data, _transfered_amount)
	_transfered_data = temp_data
	_transfered_amount = temp_amount
	reload_visual()


func reload_visual() -> void:
	_icon.texture = _transfered_data.icon
	_amount_label.text = str(_transfered_amount)
	if _transfered_amount == 1 or not _transfered_data.is_stackable:
		_amount_label.visible = false
	else:
		_amount_label.visible = true
	visible = true


func clear() -> void:
	_transfered_data = null
	_transfered_amount = 0
	_icon.texture = null
	_amount_label.text = ""
	tooltip_text = ""
	visible = false
