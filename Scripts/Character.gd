extends CharacterBody2D

class_name Character

signal on_health_changed
signal on_death

@export var speed: float = 250.0
@export var health: float = 100.0
@export var health_regen_per_second: float = 0.0
@export var max_health: float = 100.0

@onready var Walk_Sound = $Walk

var _hp_regen_accumulator: float = 0.0
func _physics_process(delta):
	#var direction = Input.get_vector("movement_left", "movement_right", "movement_up", "movement_down")
	#velocity = direction * speed * delta * 100
	#move_and_slide()
	# HP regen
	_hp_regen_accumulator += delta
	if _hp_regen_accumulator >= 1.0:
		_hp_regen_accumulator -= 1.0
		heal(health_regen_per_second)


func damage(damage_amount: float) -> void:
	if health - damage_amount <= 0.0:
		health = 0.0
		get_node("%GameOver").show()
		get_tree().paused = true
	else:
		health -= damage_amount
	on_health_changed.emit()


func heal(amount: float) -> void:
	if health + amount > max_health:
		health = max_health
	else:
		health += amount
	on_health_changed.emit()