extends CharacterBody2D

signal died

var speed = randf_range(200, 300)
var health = 3

@onready var player = get_node("/root/Game/Player")
@onready var itemsController: ItemsController = get_node("/root/ItemsController")
@onready var hitArea: Area2D = get_node("Area2D")

func _ready():
	%Slime.play_walk()


func _physics_process(_delta):
	var direction = global_position.direction_to(player.global_position)
	velocity = direction * speed
	move_and_slide()
	
	var bodies = hitArea.get_overlapping_bodies()
	for body in bodies:
		try_attack(body);

func try_attack(body):
	if body is Player:
		body.Damage(1.0)

func take_damage():
	%Slime.play_hurt()
	health -= 1

	if health == 0:
		var smoke_scene = preload("res://Assets/smoke_explosion/smoke_explosion.tscn")
		var smoke = smoke_scene.instantiate()
		var item_data: ItemData = preload("res://Resources/Items/Coin.tres")
		var item = Item.new()
		item.Set(item_data, 1)
		itemsController.call_deferred("Spawn", item_data, 1, position)
		
		get_parent().add_child(smoke)
		smoke.global_position = global_position
		queue_free()
