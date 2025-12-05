extends Node2D

class_name WandAltar

@onready var wand_inventory: InventorySystem = %WandInventory
@onready var modifier_inventory: InventorySystem = %ModifierInventory
@onready var wand_pivot: Node2D = %WandPivot
@onready var altar_ui: UIAltar = get_node("/root/Game/UI/UIControler/UIAltarMenu")
@onready var interact_hint: Node2D = %InteractHint

const WAND = preload("res://Prefabs/Wand.tscn")

func _ready() -> void:
	interact_hint.visible = false
	wand_inventory.on_inventory_changed.connect(on_wand_changed)

	altar_ui.wand_ui_inventory.set_inventory_data(wand_inventory)
	altar_ui.modifier_ui_inventory.set_inventory_data(null)

	pass

	
func on_wand_changed() -> void:
	var wand: WandData = wand_inventory.items[0].item_data as WandData
	if wand == null:
		if altar_ui.modifier_ui_inventory._inventory_system != null:
			altar_ui.modifier_ui_inventory.set_inventory_data(null)
		altar_ui.stats_label.text = "No wand equipped"
		wand_pivot.get_child(0).queue_free()
		return

	var modifier_items: Array[Item] = []
	for modifier in wand.modifiers:
		modifier_items.append(Item.new(modifier, 1))
	modifier_items.resize(wand.modifier_slot_count)
	modifier_inventory._init(modifier_items)
	altar_ui.modifier_ui_inventory.set_inventory_data(modifier_inventory)
	if !altar_ui.modifier_ui_inventory._inventory_system.on_inventory_changed.is_connected(on_modifier_changed):
		altar_ui.modifier_ui_inventory._inventory_system.on_inventory_changed.connect(on_modifier_changed)
	var wand_instance: Wand = WAND.instantiate()
	wand_instance.set_data(wand)
	wand_pivot.add_child(wand_instance)
	update_stats()

func on_modifier_changed() -> void:
	var modifiers: Array[WandModifier] = []
	for i in range(modifier_inventory.items.size()):
		if modifier_inventory.items[i] != null:
			modifiers.append(modifier_inventory.items[i].item_data as WandModifier)
	
	var wand: WandData = wand_inventory.items[0].item_data as WandData
	wand.modifiers = modifiers
	update_stats()

func update_stats() -> void:
	var wand_instance = wand_pivot.get_child(0) as Wand
	wand_instance.recalculate_modifiers()
	
	altar_ui.stats_label.text = """
		Damage: {damage}
		Cooldown: {cooldown}
		Projectile Speed: {projectile_speed}
		Projectile Range: {projectile_range}
		Mana Cost: {mana_cost}
	""".format({
		"damage": wand_instance.damage,
		"cooldown": wand_instance.cooldown_ms,
		"projectile_speed": wand_instance.projectile_speed,
		"projectile_range": wand_instance.projectile_range,
		"mana_cost": wand_instance.mana_cost,
	})


func interact() -> void:
	altar_ui.show()
	get_node("/root/Game/UI/UIControler/UIPlayerInventory").show()

func end_interaction() -> void:
	altar_ui.hide()
	get_node("/root/Game/UI/UIControler/UIPlayerInventory").hide()

func show_iteract_hint() -> void:
	interact_hint.visible = true

func hide_iteract_hint() -> void:
	interact_hint.visible = false
