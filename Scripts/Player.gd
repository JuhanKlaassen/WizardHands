extends Character

class_name Player

signal on_mana_changed
signal on_xp_changed

@export var level: int = 1
@export var xp: int = 0
@export var gold: int = 0


@export var mana: int = 0
@export var max_mana: int = 100
@export var mana_regen: int = 5
#MISC
@export var dodge: float = 0.0
@export var more_xp: float = 1
@export var more_gold:float = 1
@export var luck: float = 110

const LEVELUP_MENU = preload("res://Prefabs/UI/UILevelUpMenu.tscn") # adjust path
var levelup_menu: LevelUpMenu = null
#ajutine prg
@export var xp_to_next_level: int = 40

@export var modifier_collection: PlayerModifierCollection
@export var modifiers: Array[PlayerModifier]

@onready var _left_hand: Node2D = %LeftHand
@onready var _right_hand: Node2D = %RightHand
@onready var _inventory: InventorySystem = %Inventory
@onready var _hotbar: InventorySystem = %Hotbar
@onready var _ui_hotbar: UIPlayerHotbar = get_tree().root.get_node("Game/UI/UIControler/UIPlayerHotbar")
@onready var interaction_collider: Area2D = %InteractionCollider

var interactable = null
var interacting: bool = false
var interactables_in_range: Array[Node2D] = []

const WAND = preload("res://Prefabs/Wand.tscn")

func _ready():
	_hotbar.on_inventory_changed.connect(on_hotbar_item_changed)
	on_hurt.connect(update_health_ui)
	on_heal.connect(update_health_ui)
	on_mana_changed.connect(update_mana_ui)
	on_xp_changed.connect(update_xp_ui)
	update_health_ui()
	update_mana_ui()
	update_xp_ui()
	on_death.connect(func():
		get_node("%GameOver").show()
		get_tree().paused = true
	)

	interaction_collider.body_entered.connect(func(body):
		if body.has_method("interact"):
			interactables_in_range.append(body)
	)
	interaction_collider.body_exited.connect(func(body):
		interactables_in_range.erase(body)
		try_stop_interacting(body)
	)

	for child in _left_hand.get_children():
		_left_hand.remove_child(child)
		child.queue_free()
	for child in _right_hand.get_children():
		_right_hand.remove_child(child)
		child.queue_free()


func gain_xp(amount: int) -> void:
	xp += amount*more_xp
	print("Gained XP: ", amount*more_xp, " | Total XP: ", xp)
	
	# Update XP bar
	on_xp_changed.emit()
	
	while xp >= xp_to_next_level:
		xp -= xp_to_next_level
		level_up() # xp_to_next_level will be updated here
		
		# Immediately refresh XP bar with the new xp_to_next_level
		on_xp_changed.emit()


func level_up() -> void:
	level += 1
	print("LEVEL UP!")

	# Update XP required
	var base_xp = 40
	var exponent = 1.3
	xp_to_next_level = int(base_xp * pow(level, exponent))

	# Pause the game
	get_tree().paused = true

	# Create menu
	levelup_menu = LEVELUP_MENU.instantiate()
	get_parent().add_child(levelup_menu)

	# Randomly generate 3 options
	var choices = modifier_collection.modifiers.duplicate()
	choices.shuffle()

	# Arrays for names, values, and colors
	var names: Array = []
	var rolled_values: Array = []
	var colors: Array = []

	for i in range(3):
		names.append(choices[i].name)

		var roll_result = roll_modifier_value(choices[i], luck)
		rolled_values.append(roll_result.value)
		colors.append(roll_result.color)

	# Set menu options with names, values, and colors
	levelup_menu.set_options(names, rolled_values, colors)

	# Connect button selection
	levelup_menu.option_selected.connect(func(option_id):
		modifiers.append(choices[option_id])
		# Apply the rolled value to the player
		choices[option_id].apply(self, rolled_values[option_id])
		levelup_menu.queue_free()
		levelup_menu = null

		# Unpause game
		get_tree().paused = false
		print("Applied bonus: ", choices[option_id].name)
	)



# Returns a dictionary with 'value' and 'color'
func roll_modifier_value(mod: PlayerModifier, player_luck: float) -> Dictionary:
	var luck = clamp(player_luck, 0.0, 100.0)

	# Base chances
	var bronze_chance = 0.55
	var silver_chance = 0.30
	var gold_chance   = 0.15

	# Increase gold chance based on luck, decrease bronze
	gold_chance += luck * 0.002
	bronze_chance -= luck * 0.002

	# Clamp to valid range
	bronze_chance = clamp(bronze_chance, 0.0, 1.0)
	gold_chance   = clamp(gold_chance, 0.0, 1.0)
	silver_chance = clamp(1.0 - bronze_chance - gold_chance, 0.0, 1.0)

	# Roll random
	var r = randf()
	var val: float

	if r < gold_chance:
		val = mod.value1  # gold = rarest
	elif r < gold_chance + silver_chance:
		val = mod.value2  # silver = middle
	else:
		val = mod.value3  # bronze = lowest

	# Determine color based on rarity
	var sorted_values = [mod.value1, mod.value2, mod.value3]
	sorted_values.sort_custom(func(a, b): return b - a) # descending

	var color: Color
	if val == sorted_values[0]:
		color = Color(1, 0.84, 0)       # gold = best
	elif val == sorted_values[1]:
		color = Color(0.75, 0.75, 0.75) # silver = middle
	else:
		color = Color(0.8, 0.5, 0.2)    # bronze = lowest

	# Debug print
	print("Rolled value:", val, "Color:", color, "Luck:", luck, "r:", r)
	return {"value": val, "color": color}




var _mana_regen_accumulator: float = 0.0
func _physics_process(delta):
	super._physics_process(delta)
	var direction = Input.get_vector("movement_left", "movement_right", "movement_up", "movement_down")
	velocity = direction * speed * delta * 100
	move_and_slide()
	
	if velocity.length() > 0.0:
		%HappyBoo.play_walk_animation()
		if not Walk_Sound.playing:
			Walk_Sound.play()
	else:
		%HappyBoo.play_idle_animation()

	var mouse_pos = get_global_mouse_position()
	_left_hand.look_at(mouse_pos)
	_right_hand.look_at(mouse_pos)

	for interactable_in_range in interactables_in_range:
		if interactable == interactable_in_range:
			continue

		if interactable == null:
			interactable = interactable_in_range
			interactable.show_iteract_hint()
			continue

		if interacting:
			return
			
		var distance1 = global_position.distance_to(interactable_in_range.global_position)
		var distance2 = global_position.distance_to(interactable.global_position)
		if distance1 < distance2:
			try_stop_interacting(interactable)
			interactable = interactable_in_range
			interactable.show_iteract_hint()


	# Mana regen
	_mana_regen_accumulator += delta
	if _mana_regen_accumulator >= 1.0:
		_mana_regen_accumulator -= 1.0
		restore_mana(mana_regen)

func restore_mana(amount: int) -> void:
	mana += amount
	if mana > max_mana:
		mana = max_mana
	
	on_mana_changed.emit()


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("interact"):
		if interactable != null:
			interacting = true
			if interactable.interact() == false:
				interacting = false

	elif event.is_action_pressed("cancel"):
		if interacting:
			interacting = false
			interactable.end_interaction()

func consume_mana(amount: int) -> bool:
	if mana >= amount:
		mana -= amount
		on_mana_changed.emit()
		return true
	else:
		return false


func remove_gold(amount: int) -> bool:
	if gold < amount:
		return false

	gold -= amount
	$gold.text = str(gold)
	return true


func add_gold(amount):
	gold += int(floor(amount * more_gold + 0.5))
	$gold.text = 'GOLD '+str(gold)

func pick_up_item(item: Item) -> bool:
	return _inventory.add_items(item.item_data, item.amount)

var shoot_lambda = func(wand):
	if consume_mana(wand.get_mana_cost()):
		wand.shoot()

func on_hotbar_item_changed():
	var _left_item = null
	if _left_hand.get_child_count() != 0:
		_left_item = _left_hand.get_child(0)
	if _left_item != _hotbar.items[0]:
		if _left_item != null:
			_left_hand.remove_child(_left_item)
			_left_item.queue_free()
			
		if _hotbar.items[0] != null and _hotbar.items[0].item_data != null:
			var wand: Wand = WAND.instantiate()
			wand.set_data(_hotbar.items[0].item_data)
			var slot = _ui_hotbar.get_slot(0)
			wand.on_cooldown_changed.connect(slot.set_cooldown)
			var shoot_lambda_func = shoot_lambda.bind(wand)
			if !slot.on_slot_action_called.is_connected(shoot_lambda_func):
				slot.on_slot_action_called.connect(shoot_lambda_func)
			wand.tree_exiting.connect(func():
				slot.on_slot_action_called.disconnect(shoot_lambda_func)
			)
			_left_hand.add_child(wand)

	var _right_item = null
	if _right_hand.get_child_count() != 0:
		_right_item = _right_hand.get_child(0)
	if _right_item != _hotbar.items[1]:
		if _right_item != null:
			_right_hand.remove_child(_right_item)
			_right_item.queue_free()
			
		if _hotbar.items[1] != null and _hotbar.items[1].item_data != null:
			var wand: Wand = WAND.instantiate()
			wand.set_data(_hotbar.items[1].item_data)
			var slot = _ui_hotbar.get_slot(1)
			wand.on_cooldown_changed.connect(slot.set_cooldown)
			var shoot_lambda_func = shoot_lambda.bind(wand)
			if !slot.on_slot_action_called.is_connected(shoot_lambda_func):
				slot.on_slot_action_called.connect(shoot_lambda_func)
			wand.tree_exiting.connect(func():
				slot.on_slot_action_called.disconnect(shoot_lambda_func)
			)
			_right_hand.add_child(wand)


func try_stop_interacting(body) -> void:
	if body.has_method("interact"):
		if interactable == body:
			if interacting:
				interacting = false
				interactable.end_interaction()
			interactable.hide_iteract_hint()
			interactable = null
		

func update_health_ui() -> void:
	$HealthBar.value = health
	$HealthBar.max_value = max_health
	$HealthBar/Label.text = str(health) + '/' + str(max_health)

func update_mana_ui() -> void:
	$ManaBar.value = mana
	$ManaBar.max_value = max_mana
	$ManaBar/Label.text = str(mana) + '/' + str(max_mana)

func update_xp_ui() -> void:
	$XpBar.value = xp
	$XpBar.max_value = xp_to_next_level
	$XpBar/Label.text = str(xp) + '/' + str(xp_to_next_level)
