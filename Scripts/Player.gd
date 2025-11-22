extends CharacterBody2D

class_name Player

@export var _speed: float = 250.0
@export var _health: float = 100.0

@onready var _left_hand: Node2D = %LeftHand
@onready var _right_hand: Node2D = %RightHand
@onready var _inventory: InventorySystem = %Inventory
@onready var _hotbar: InventorySystem = %Hotbar

const WAND = preload("res://Prefabs/Wand.tscn")

func _ready():
	_hotbar.on_inventory_changed.connect(on_hotbar_item_changed)
	for child in _left_hand.get_children():
		_left_hand.remove_child(child)
		child.queue_free()
	for child in _right_hand.get_children():
		_right_hand.remove_child(child)
		child.queue_free()

func _physics_process(delta):
	var direction = Input.get_vector("movement_left", "movement_right", "movement_up", "movement_down")
	velocity = direction * _speed * delta * 100

	move_and_slide()
	
	if velocity.length() > 0.0:
		%HappyBoo.play_walk_animation()
	else:
		%HappyBoo.play_idle_animation()

	var mouse_pos = get_global_mouse_position()
	_left_hand.look_at(mouse_pos)
	_right_hand.look_at(mouse_pos)


func damage(damage_amount: float) -> void:
	if _health - damage_amount <= 0.0:
		_health = 0.0
		get_node("%GameOver").show()
		get_tree().paused = true
	else:
		_health -= damage_amount


	get_node("%HealthBar").value = _health


func pick_up_item(item: Item) -> bool:
	return _inventory.add_items(item.item_data, item.amount)

func on_hotbar_item_changed():
	var _left_item = null
	if _left_hand.get_child_count() != 0:
		_left_item = _left_hand.get_child(0)
	if _left_item != _hotbar.items[0]:
		var wand: Wand = null;
		if _hotbar.items[0] != null and _hotbar.items[0].item_data != null:
			wand = WAND.instantiate()
			wand.set_data(_hotbar.items[0].item_data)

		if _left_item != null:
			_left_hand.remove_child(_left_item)
			_left_item.queue_free()

		if wand != null:
			_left_hand.add_child(wand)
	
	var _right_item = null
	if _right_hand.get_child_count() != 0:
		_right_item = _right_hand.get_child(0)
	if _right_item != _hotbar.items[1]:
		var wand: Wand = null;
		if _hotbar.items[1] != null and _hotbar.items[1].item_data != null:
			wand = WAND.instantiate()
			wand.set_data(_hotbar.items[1].item_data)

		if _right_item != null:
			_right_hand.remove_child(_right_item)
			_right_item.queue_free()

		if wand != null:
			_right_hand.add_child(wand)
