extends CharacterBody2D

var speed = randf_range(350, 400)
var health = 2
var xp = 40

@onready var player = get_node("/root/Game/Player")
@onready var itemsController: ItemsController = get_node("/root/ItemsController")
@onready var hitArea: Area2D = get_node("Area2D")

func _ready():
	pass


func _physics_process(_delta):
	look_at(player.global_position)
	
	var direction = global_position.direction_to(player.global_position)
	velocity = direction * speed
	move_and_slide()
	
	var bodies = hitArea.get_overlapping_bodies()
	for body in bodies:
		try_attack(body);

func try_attack(body):
	if body.has_method("damage"):
		body.damage(1.0)

func take_damage(damage: float):
	%Rat.play_hurt()
	health -= damage

	if health <= 0:
		var smoke_scene = preload("res://Assets/smoke_explosion/smoke_explosion.tscn")
		var smoke = smoke_scene.instantiate()
		var item_data: ItemData = preload("res://Resources/Items/Coin.tres")
		var item = Item.new()
		item.set_item_data(item_data, 1)
		itemsController.spawn(item_data, 1, position)
		if player != null and player.has_method("gain_xp"):
			player.gain_xp(xp)
		get_parent().add_child(smoke)
		smoke.global_position = global_position
		queue_free()
