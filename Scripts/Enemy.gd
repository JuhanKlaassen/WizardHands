extends Character

class_name Enemy

@export var enemy_data: EnemyData

@onready var player = get_node("/root/Game/Player")
@onready var hit_area: Area2D = get_node("Area2D")

const ENEMY = preload("res://Prefabs/Enemy.tscn")

static func new_enemy(data: EnemyData) -> Enemy:
	var enemy_scene: Enemy = ENEMY.instantiate()
	
	enemy_scene.set_data(data)
	return enemy_scene


func _init():
	super._init()
	if enemy_data != null:
		set_data(enemy_data)
	on_death.connect(die)


func set_data(data: EnemyData) -> void:
	if enemy_data != null:
		printerr("Enemy data already set!")
		return
	speed = data.speed
	health = data.health
	max_health = data.health
	var enemy_scene = data.enemy_scene.instantiate()
	enemy_scene.position = data.offset
	enemy_scene.rotation_degrees = data.rotation
	enemy_scene.scale = data.scale
	self.add_child(enemy_scene)
	enemy_data = data
	on_hurt.connect(func():
		enemy_scene.play_hurt()
	)
	enemy_scene.play_walk()


func _physics_process(_delta):
	super._physics_process(_delta)
	if enemy_data.look_at:
		look_at(player.global_position)

	var direction = global_position.direction_to(player.global_position)
	velocity = direction * speed
	move_and_slide()
	
	var bodies = hit_area.get_overlapping_bodies()
	for body in bodies:
		if body.has_method("take_damage"):
			body.take_damage(enemy_data.damage)


func die():
	var smoke_scene = preload("res://Assets/smoke_explosion/smoke_explosion.tscn")
	var smoke = smoke_scene.instantiate()
	
	player.add_gold(1)
	
	if player != null and player.has_method("gain_xp"):
		player.gain_xp(enemy_data.xp)
	get_parent().add_child(smoke)
	smoke.global_position = global_position
	queue_free()
