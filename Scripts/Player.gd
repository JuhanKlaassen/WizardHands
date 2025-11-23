extends CharacterBody2D

class_name Player

@export var _speed: float = 250.0
@export var _health: int = 100
@export var level: int = 1
@export var xp: int = 0
var _hp_regen_accumulator: float = 0.0
@export var hp_regen_rate: float = 1.0 # HP per second
#ajutine prg
@export var xp_to_next_level: int = 50

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

func gain_xp(amount: int) -> void:
	xp += amount
	print("Gained XP: ", amount, " | Total XP: ", xp)
	
	# Update the XP bar
	%xpbar.value = xp
	$xpbar/Label.text = str(xp)+'/'+str(xp_to_next_level)
	
	while xp >= xp_to_next_level:
		xp -= xp_to_next_level
		level_up()
		
		# Reset XP bar for next level
		%xpbar.max_value = xp_to_next_level
		%xpbar.value = xp
		$xpbar/Label.text = str(xp)+'/'+str(xp_to_next_level)

func level_up() -> void:
	level += 1
	print("Level UP! Now level ", level)

	# Choose a random bonus: 0 = max HP, 1 = speed, 2 = HP regen
	var bonus = randi() % 3
	var popup_text = ""

	match bonus:
		0:
			var hp_increase = 20
			_health += hp_increase
			%HealthBar.max_value += hp_increase
			%HealthBar.value += hp_increase
			$HealthBar/Label.text = str(_health)+'/'+str(%HealthBar.max_value)
			popup_text = "+%d Max HP" % hp_increase
		1:
			var speed_increase = 30
			_speed += speed_increase
			popup_text = "+%d Speed" % speed_increase
		2:
			var regen_increase = 1
			hp_regen_rate += regen_increase
			popup_text = "+%d HP Regen/sec" % regen_increase

	# Spawn smoke effect on player
	var smoke_scene = preload("res://Assets/smoke_explosion/smoke_explosion.tscn")
	var smoke = smoke_scene.instantiate()
	get_parent().add_child(smoke)
	smoke.global_position = global_position

	# Spawn popup above player
	var popup_scene = preload("res://Prefabs/level_up_popup.tscn")
	var popup = popup_scene.instantiate()
	get_parent().add_child(popup)
	popup.global_position = global_position + Vector2(0, -40) # above player
	popup.text = popup_text


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
	
	_hp_regen_accumulator += delta
	if _hp_regen_accumulator >= 1.0:
		_hp_regen_accumulator -= 1.0
		heal(1) # heal 1 HP per second

func heal(amount: int) -> void:
	_health += amount
	if _health > %HealthBar.max_value:
		_health = %HealthBar.max_value
	
	$HealthBar.value = _health
	$HealthBar/Label.text = str(_health)+'/'+str(%HealthBar.max_value)


func damage(damage_amount: float) -> void:
	if _health - damage_amount <= 0.0:
		_health = 0.0
		get_node("%GameOver").show()
		get_tree().paused = true
	else:
		_health -= damage_amount

	$HealthBar/Label.text = str(_health)+'/'+str(%HealthBar.max_value)
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
