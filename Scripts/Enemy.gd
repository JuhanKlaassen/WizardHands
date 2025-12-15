extends Character

class_name Enemy

@export var enemy_data: EnemyData
@export var xp: int = 0

@onready var player = get_node("/root/Game/Player")
@onready var hit_area: Area2D = get_node("Area2D")

# Orbiter data
var is_orbit_enemy: bool = false
var orbit_radius: float = 150.0
var orbit_speed: float = 2.0
var spawn_timer: float = 0.0
var spawn_interval: float = 4.0
var orbit_angle: float = 0.0
var orbit_direction: int = 1

signal request_minion_spawn(position: Vector2, data: EnemyData)

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
	xp = data.xp
	var enemy_scene = data.enemy_scene.instantiate()
	enemy_scene.position = data.offset
	enemy_scene.rotation_degrees = data.rotation
	enemy_scene.scale = data.scale
	self.add_child(enemy_scene)
	enemy_data = data
	if "orbit" in data.resource_path.to_lower():
		is_orbit_enemy = true
		orbit_direction = 1 if randf() > 0.5 else -1  # random orbit direction
		spawn_timer = randf_range(1.0, 3.0)  # random first spawn

	on_hurt.connect(func():
		enemy_scene.play_hurt()
	)
	enemy_scene.play_walk()


func _physics_process(_delta):
	super._physics_process(_delta)
	if enemy_data.look_at:
		look_at(player.global_position)
	if is_orbit_enemy and player:

		orbit_angle += orbit_speed * _delta * orbit_direction
		
		var orbit_x = cos(orbit_angle) * orbit_radius
		var orbit_y = sin(orbit_angle) * orbit_radius
		var target_position = player.global_position + Vector2(orbit_x, orbit_y)
		
		var direction = (target_position - global_position).normalized()
		velocity = direction * speed
		
		spawn_timer -= _delta
		if spawn_timer <= 0:
			spawn_minion()
			spawn_timer = spawn_interval
		
		# Look at player (orbiting)
		look_at(player.global_position)
		
	else:
		if enemy_data.look_at:
			look_at(player.global_position)

		var direction = global_position.direction_to(player.global_position)
		velocity = direction * speed
	move_and_slide()
	
	var bodies = hit_area.get_overlapping_bodies()
	for body in bodies:
		if body.has_method("take_damage"):
			body.take_damage(enemy_data.damage)

func spawn_minion():
	if not player or not is_orbit_enemy:
		return
	
	# Spawn a smaller, weaker enemy
	print("Orbit enemy spawning minion!")
	
	# Visual effect
	var spawn_effect = preload("res://Assets/smoke_explosion/smoke_explosion.tscn").instantiate()
	spawn_effect.scale = Vector2(0.5, 0.5)
	get_parent().add_child(spawn_effect)
	spawn_effect.global_position = global_position

	var minion_data = enemy_data.duplicate()
	minion_data.speed = speed * 1.5  # faster minions
	minion_data.health = 1  # low health
	minion_data.damage = 1
	minion_data.xp = 0  # low XP

	emit_signal("request_minion_spawn", global_position, enemy_data)

func die():
	var smoke_scene = preload("res://Assets/smoke_explosion/smoke_explosion.tscn")
	var smoke = smoke_scene.instantiate()
	
	player.add_gold(1)
	
	if player != null and player.has_method("gain_xp"):
		player.gain_xp(xp)
	get_parent().add_child(smoke)
	smoke.global_position = global_position
	queue_free()
