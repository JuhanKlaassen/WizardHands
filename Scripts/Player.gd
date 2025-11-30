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

const LEVELUP_MENU = preload("res://Scenes/level_up_menu.tscn") # adjust path
var levelup_menu: LevelUpMenu = null
#ajutine prg
@export var xp_to_next_level: int = 40


@onready var _left_hand: Node2D = %LeftHand
@onready var _right_hand: Node2D = %RightHand
@onready var _inventory: InventorySystem = %Inventory
@onready var _hotbar: InventorySystem = %Hotbar
@onready var _ui_hotbar: UIPlayerHotbar = get_tree().root.get_node("Game/UI/UIControler/UIPlayerHotbar")
const WAND = preload("res://Prefabs/Wand.tscn")

func _ready():
	_hotbar.on_inventory_changed.connect(on_hotbar_item_changed)
	on_health_changed.connect(update_health_ui)
	on_mana_changed.connect(update_mana_ui)
	on_xp_changed.connect(update_xp_ui)
	update_health_ui()
	update_mana_ui()
	update_xp_ui()
	on_death.connect(func():
		get_node("%GameOver").show()
		get_tree().paused = true
	)
	
	for child in _left_hand.get_children():
		_left_hand.remove_child(child)
		child.queue_free()
	for child in _right_hand.get_children():
		_right_hand.remove_child(child)
		child.queue_free()

func gain_xp(amount: int) -> void:
	xp += amount
	print("Gained XP: ", amount, " | Total XP: ", xp)
	
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
	var choices = [
		{"id": 0, "text": "+20 Max HP"},
		{"id": 1, "text": "+30 Speed"},
		{"id": 2, "text": "+1 HP Regen/sec"},
		{"id": 3, "text": "+5 Max Mana"},
		{"id": 4, "text": "+1 Mana Regen"},
		{"id": 5, "text": "+5% Dodge"}
	]

	choices.shuffle()

	# show 3
	levelup_menu.set_options(
		choices[0].text,
		choices[1].text,
		choices[2].text
	)

	# Wait for a click
	levelup_menu.option_selected.connect(
		func(option_id):
			_apply_levelup_bonus(choices[option_id].id)
	)


func _apply_levelup_bonus(bonus_id: int):
	match bonus_id:
		0:
			if health == max_health:
				health += 20
			max_health += 20
			on_health_changed.emit()
		1:
			speed += 30
		2:
			health_regen_per_second += 1
		3:
			max_mana += 5
			mana += 5
			on_mana_changed.emit()
		4:
			mana_regen += 1
		5:
			dodge += 0.05

	# Close menu
	levelup_menu.queue_free()
	levelup_menu = null

	# Unpause game
	get_tree().paused = false

	print("Applied bonus: ", bonus_id)


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


func consume_mana(amount: int) -> bool:
	if mana >= amount:
		mana -= amount
		on_mana_changed.emit()
		return true
	else:
		return false


func add_gold(amount):
	gold += amount
	$gold.text = str(gold)

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
			
		if _hotbar.items[0] == null or _hotbar.items[0].item_data == null:
			return

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
			
		if _hotbar.items[1] == null or _hotbar.items[1].item_data == null:
			return

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
