extends Node2D

class_name ShopStand

@onready var item_sprite: Sprite2D = %ItemSprite
@onready var price_label: Label = %PriceLabel
@onready var interact_hint: Node2D = %InteractHint
@onready var player: Player = get_node("/root/Game/Player")

var item: Item
var price: int

func _ready() -> void:
	interact_hint.visible = false

func set_offer(new_item: Item, new_price: int) -> void:
	if new_item == null:
		item = null
		price = 0
		item_sprite.texture = null
		price_label.text = ""
		return
	
	item = new_item
	price = new_price
	item_sprite.texture = item.item_data.icon
	price_label.text = str(price) + "$"

func interact() -> bool:
	if item == null:
		return false

	print("Buy")
	if player.remove_gold(price) == false:
		return false
		
	if player._inventory.add_items(item.item_data, item.amount) == false:
		return false

	item = null
	price = 0
	item_sprite.texture = null
	price_label.text = ""

	hide_iteract_hint()

	return false

func end_interaction() -> void:
	pass

func show_iteract_hint() -> void:
	if item == null:
		return
	interact_hint.visible = true

func hide_iteract_hint() -> void:
	interact_hint.visible = false
