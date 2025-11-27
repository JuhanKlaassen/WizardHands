extends RigidBody2D

class_name GroundItem

@export var _icon: Sprite2D
@export var _amount_label: Label
var _item: Item

@onready var _items_controller: ItemsController = ItemsController
var _pickup_collider: Area2D

var item: Item:
	get:
		return _item


func _ready() -> void:
	add_to_group("ground_items")
	_pickup_collider = get_node("Area2D")
	_pickup_collider.body_entered.connect(_on_body_entered)


func set_item(new_item: Item) -> void:
	_item = new_item
	_icon.texture = _item.item_data.icon
	_amount_label.text = str(_item.amount)


func _on_body_entered(body: Node2D) -> void:
	if !body.has_method("pick_up_item"):
		return

	if body.pick_up_item(self._item):
		queue_free()


func try_stack(ground_item: GroundItem) -> bool:
	if ground_item.get_instance_id() < get_instance_id():
		return false


	var temp_amount: int = _item.amount + ground_item.item.amount - _item.item_data.max_stack
	if temp_amount > 0:
		_item.add(_item.amount - _item.item_data.max_stack)
		_items_controller.spawn(_item.item_data, temp_amount, position)
	else:
		_item.add(ground_item.item.amount)


	_amount_label.text = str(_item.amount)
	return true
