extends Panel

class_name UISlot

signal on_slot_clicked(input_event: InputEvent)
signal on_slot_action_called

@onready var _icon: TextureRect = get_node("MarginContainer/TextureRect")
@onready var _amount_label: Label = get_node("MarginContainer/AmountLabel")
@onready var _cooldown_label: Label = $CooldownLabel
@export var _item: Item
@export var _slot_type: ItemData.ItemType = ItemData.ItemType.UNSET

var icon: TextureRect:
	get:
		return _icon

var amount_label: Label:
	get:
		return _amount_label

var item: Item:
	get:
		return _item

var slot_type: ItemData.ItemType:
	get:
		return _slot_type

func _ready() -> void:
	gui_input.connect(_on_gui_input)


func set_item(new_item: Item) -> void:
	_item = new_item
	reload()
	new_item.item_changed.connect(reload)

func set_cooldown(new_cooldown: float) -> void:
	if new_cooldown > 0.0:
		_cooldown_label.visible = true
		_cooldown_label.text = str(new_cooldown)
	else:
		_cooldown_label.visible = false

func reload() -> void:
	if _item != null and _item.item_data != null:
		_icon.texture = _item.item_data.icon
		_amount_label.text = str(_item.amount)
		tooltip_text = _item.item_data.name + "\n\n" + _item.item_data.description


		if _item.amount == 1 or not _item.item_data.is_stackable:
			_amount_label.visible = false
		else:
			_amount_label.visible = true
	else:
		_icon.texture = null
		_amount_label.text = ""
		_amount_label.visible = false
		tooltip_text = ""


func _on_gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		var mouse_button: InputEventMouseButton = event as InputEventMouseButton
		if mouse_button.pressed:
			on_slot_clicked.emit(event)
