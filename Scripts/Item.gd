extends Resource

class_name Item

signal item_changed

@export var _item_data: ItemData
@export var _amount: int

var item_data: ItemData:
	get:
		return _item_data

var amount: int:
	get:
		return _amount


func _init(new_item_data: ItemData = null, new_amount: int = 0) -> void:
	if new_item_data != null and new_amount > 0:
		set_item_data(new_item_data, new_amount)
	else:
		_item_data = null
		_amount = 0


func set_item_data(new_item_data: ItemData, new_amount: int) -> void:
	if new_item_data != null and new_amount > new_item_data.max_stack:
		push_error("Item Amount cant be more than MaxStack. Setting to MaxStack(" + str(new_item_data.max_stack) + ")!")
		new_amount = new_item_data.max_stack
	elif new_amount < 0:
		push_error("Item Amount cant be less than 1. Setting to 1!")
		new_amount = 1


	_item_data = new_item_data
	_amount = new_amount


	item_changed.emit()


func add(new_amount: int) -> void:
	if _item_data == null:
		push_error("ItemData is null")
		return


	if (_amount + new_amount) > _item_data.max_stack:
		push_error("Item Amount cant be more than MaxStack")
		return
	if new_amount < 0:
		push_error("Item Amount cant be less than 0")
		return

	_amount += new_amount


	item_changed.emit()


func remove(new_amount: int) -> void:
	if _item_data == null:
		push_error("ItemData is null")
		return
	if (_amount - new_amount) < 0:
		push_error("Cant Stack Items")
		return

	_amount -= new_amount


	if _amount == 0:
		_item_data = null


	item_changed.emit()
