extends Node

class_name InventorySystem

signal on_inventory_changed

@export var _items: Array[Item]
@export var inventory_type: ItemData.ItemType = ItemData.ItemType.UNSET

var items: Array[Item]:
	get:
		return _items


func _init(new_items: Array[Item] = []) -> void:
	if new_items.is_empty():
		_items = []
	else:
		_items = new_items


func _enter_tree() -> void:
	if _items == null or _items.is_empty():
		_items = []


	for i in range(_items.size()):
		if _items[i] == null:
			_items[i] = Item.new(null, 0)


func add_items(item_data: ItemData, amount: int = -1) -> bool:
	if count_available_item_space(item_data) < amount:
		return false;

	var not_full_items: Array[Item] = get_not_full_items(item_data)


	for item in not_full_items:
		var amount_to_add: int = item.item_data.max_stack - item.amount
		if amount > amount_to_add:
			item.add(amount_to_add)
			amount -= amount_to_add
		else:
			item.add(amount)
			amount = 0
			break


	if amount > 0:
		var empty_slots: Array[Item] = get_empty_slots()


		for item in empty_slots:
			var amount_to_add: int = item_data.max_stack
			if amount > amount_to_add:
				item.set_item_data(item_data, amount_to_add)
				amount -= amount_to_add
			else:
				item.set_item_data(item_data, amount)
				amount = 0
				break


	on_inventory_changed.emit()


	if amount > 0:
		push_error("InventorySystem.add_items: Error adding all items.")

	return true


func remove_items(item_data: ItemData, amount: int) -> void:
	if count_items(item_data) < amount:
		push_error("InventorySystem.remove_items: Dont have enough items.")
		return

	var items_to_remove: Array[Item] = get_items(item_data)
	for item in items_to_remove:
		var amount_to_remove: int = item.amount
		if amount > amount_to_remove:
			item.remove(amount_to_remove)
			amount -= amount_to_remove
		else:
			item.remove(amount)
			amount = 0
			break


	on_inventory_changed.emit()


	if amount > 0:
		push_error("InventorySystem.remove_items: Could not remove all items.")


func count_items(item_data: ItemData) -> int:
	var count: int = 0
	for item in _items:
		if item.item_data == item_data:
			count += item.amount
	return count


func count_empty_slots() -> int:
	var count: int = 0
	for item in _items:
		if item.item_data == null:
			count += 1
	return count


func count_not_full_slot_spaces(item_data: ItemData) -> int:
	var count: int = 0
	for item in get_not_full_items(item_data):
		count += item.item_data.max_stack - item.amount
	return count


func count_available_item_space(item_data: ItemData) -> int:
	return (count_empty_slots() * item_data.max_stack) + count_not_full_slot_spaces(item_data)


func get_items(item_data: ItemData) -> Array[Item]:
	var items_result: Array[Item] = []
	for item in _items:
		if item.item_data == item_data:
			items_result.append(item)
	return items_result


func get_not_full_items(item_data: ItemData) -> Array[Item]:
	var items_result: Array[Item] = []
	for item in _items:
		if item.item_data == item_data and item.amount < item.item_data.max_stack:
			items_result.append(item)
	return items_result


func get_empty_slots() -> Array[Item]:
	var items_result: Array[Item] = []
	for item in _items:
		if item.item_data == null:
			items_result.append(item)
	return items_result


func get_inventory() -> InventorySystem:
	return self
