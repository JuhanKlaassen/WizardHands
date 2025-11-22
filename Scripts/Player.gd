extends CharacterBody2D

class_name Player

@export var speed: float = 250.0
@export var health: float = 100.0

func _physics_process(delta):
	var direction = Input.get_vector("movement_left", "movement_right", "movement_up", "movement_down")
	velocity = direction * speed * delta * 100

	move_and_slide()
	
	if velocity.length() > 0.0:
		%HappyBoo.play_walk_animation()
	else:
		%HappyBoo.play_idle_animation()

func damage(damage_amount: float) -> void:
	if health - damage_amount <= 0.0:
		health = 0.0
		get_node("%GameOver").show()
		get_tree().paused = true
	else:
		health -= damage_amount


	get_node("%HealthBar").value = health


func pick_up_item(item: Item) -> bool:
	return %Inventory.add_items(item.item_data, item.amount)
