extends CharacterBody2D

class_name Character

signal on_hurt
signal on_heal
signal on_death

var health: float
@export var speed: float = 250.0
@export var health_regen_per_second: float = 0.0
@export var max_health: float = 100.0

@onready var Walk_Sound = $Walk

func _init() -> void:
	health = max_health

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


func take_damage(damage: float) -> void:
	if health - damage <= 0.0:
		health = 0.0
		on_death.emit()
	else:
		health -= damage
	on_hurt.emit()


func heal(amount: float) -> void:
	if health + amount > max_health:
		health = max_health
	else:
		health += amount
	on_heal.emit()
