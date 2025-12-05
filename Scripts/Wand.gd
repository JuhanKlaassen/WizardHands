extends Node2D

class_name Wand

signal on_cooldown_changed(cooldown: float)

var _wand_data: WandData

@onready var shooting_sound = $ShootingSound
@onready var shooting_point = %ShootingPoint
@onready var sprite = %Sprite

var damage: int
var cooldown_ms: int
var projectile_speed: int
var projectile_range: int
var mana_cost: int

var last_shot: float = 0.0
var cooldown: float = 0.0

func _ready() -> void:
	if _wand_data != null:
		sprite.texture = _wand_data.wand_sprite
		shooting_point.position = _wand_data.shooting_point_offset
	recalculate_modifiers()

func _process(_delta: float) -> void:
	if cooldown > 0.0:
		cooldown = last_shot + cooldown_ms - Time.get_ticks_msec()
		on_cooldown_changed.emit(cooldown)

func recalculate_modifiers() -> void:
	damage = _wand_data.base_damage
	cooldown_ms = _wand_data.base_cooldown_ms
	projectile_speed = _wand_data.base_projectile_speed
	projectile_range = _wand_data.base_projectile_range
	mana_cost = _wand_data.base_mana_cost
	for modifier: WandModifier in _wand_data.modifiers:
		if modifier == null:
			continue
		modifier.apply(self)

func set_data(new_wand_data: WandData) -> void:
	_wand_data = new_wand_data

	
func get_mana_cost() -> int:
	return mana_cost

func shoot():
	if cooldown > 0.0:
		return
	
	last_shot = Time.get_ticks_msec()
	cooldown = cooldown_ms
	shooting_sound.play()
	var projectile: Projectile = _wand_data.projectile_prefab.instantiate()
	projectile.init(projectile_speed, projectile_range, damage)
	projectile.global_transform = shooting_point.global_transform
	get_tree().current_scene.add_child(projectile)
