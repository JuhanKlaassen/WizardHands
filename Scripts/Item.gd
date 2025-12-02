extends Resource

class_name Item

signal item_changed

@export var item_data: ItemData
@export var amount: int


func _init(new_item_data: ItemData = null, new_amount: int = 0) -> void:
	if new_item_data != null and new_amount > 0:
		set_item_data(new_item_data, new_amount)
	elif new_item_data == null && item_data != null && amount <= 0:
		amount = 1
	else:
		item_data = null
		amount = 0

func set_item_data(new_item_data: ItemData, new_amount: int) -> void:
	if new_item_data != null and new_amount > new_item_data.max_stack:
		push_error("Item Amount cant be more than MaxStack. Setting to MaxStack(" + str(new_item_data.max_stack) + ")!")
		new_amount = new_item_data.max_stack
	elif new_amount < 0:
		push_error("Item Amount cant be less than 1. Setting to 1!")
		new_amount = 1


	item_data = new_item_data
	amount = new_amount


	item_changed.emit()


func add(new_amount: int) -> void:
	if item_data == null:
		push_error("ItemData is null")
		return


	if (amount + new_amount) > item_data.max_stack:
		push_error("Item Amount cant be more than MaxStack")
		return
	if new_amount < 0:
		push_error("Item Amount cant be less than 0")
		return

	amount += new_amount


	item_changed.emit()


func remove(new_amount: int) -> void:
	if item_data == null:
		push_error("ItemData is null")
		return
	if (amount - new_amount) < 0:
		push_error("Cant Stack Items")
		return

	amount -= new_amount


	if amount == 0:
		item_data = null


	item_changed.emit()
