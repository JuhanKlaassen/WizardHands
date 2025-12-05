@tool
extends Panel

class_name UISlot

signal on_slot_clicked(input_event: InputEvent)
signal on_slot_action_called

@onready var icon: TextureRect = get_node("MarginContainer/TextureRect")
@onready var amount_label: Label = get_node("MarginContainer/AmountLabel")
@onready var cooldown_label: Label = $CooldownLabel
@onready var type_sprite: Sprite2D = $TypeSprite
@export var item: Item
@export var slot_type: ItemData.ItemType = ItemData.ItemType.UNSET:
	set(value):
		slot_type = value
		_update_type_sprite()

func _ready() -> void:
	if Engine.is_editor_hint():
		_update_type_sprite()
		return
	gui_input.connect(_on_gui_input)
	if slot_type == ItemData.ItemType.UNSET:
		type_sprite.visible = false
	_update_type_sprite()


func _update_type_sprite() -> void:
	if not is_node_ready():
		return

	if slot_type == ItemData.ItemType.UNSET:
		type_sprite.visible = false
	else:
		type_sprite.visible = true
		match slot_type:
			ItemData.ItemType.WAND:
				type_sprite.texture = load("res://Sprites/BlueWand.png")
			ItemData.ItemType.WAND_MODIFIER:
				type_sprite.texture = load("res://Sprites/BlueBook.png")
			_:
				type_sprite.texture = null

func set_item(new_item: Item) -> void:
	item = new_item
	reload()
	if !new_item.item_changed.is_connected(reload):
		new_item.item_changed.connect(reload)

func set_cooldown(new_cooldown: float) -> void:
	if new_cooldown > 0.0:
		cooldown_label.visible = true
		cooldown_label.text = str(new_cooldown)
	else:
		cooldown_label.visible = false

func reload() -> void:
	if item != null and item.item_data != null:
		icon.texture = item.item_data.icon
		amount_label.text = str(item.amount)
		tooltip_text = item.item_data.name + "\n\n" + item.item_data.description


		if item.amount == 1 or not item.item_data.is_stackable:
			amount_label.visible = false
		else:
			amount_label.visible = true

		type_sprite.visible = false
	else:
		icon.texture = null
		amount_label.text = ""
		amount_label.visible = false
		tooltip_text = ""
		if slot_type != ItemData.ItemType.UNSET:
			type_sprite.visible = true


func _on_gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		var mouse_button: InputEventMouseButton = event as InputEventMouseButton
		if mouse_button.pressed:
			on_slot_clicked.emit(event)
			print("on_slot_clicked.emit ", get_parent().get_parent().get_parent().name)

func transfer_to(to_slot: UISlot, amount: int = -1) -> void:
	if amount == -1:
		amount = item.amount
	
	if to_slot.item.item_data != null and to_slot.item.item_data != item.item_data:
		push_error("UITransferSlot.transfer_to | Can't transfer items of different types")
		return
	
	if to_slot.item.item_data == null:
		to_slot.item.set_item_data(item.item_data, amount)
	else:
		if to_slot.item.amount + amount > to_slot.item.item_data.max_stack:
			push_error("UITransferSlot.transfer_to | Can't transfer items, target slot will be overflown")
			return
		
		to_slot.item.add(amount)
	
	if item.amount - amount > 0:
		item.remove(amount)
		reload()
	else:
		item.set_item_data(null, 0)

func swap_with(slot: UISlot) -> void:
	var temp_data: ItemData = slot.item.item_data
	var temp_amount: int = slot.item.amount
	
	slot.item.set_item_data(item.item_data, item.amount)
	item.set_item_data(temp_data, temp_amount)
	reload()
