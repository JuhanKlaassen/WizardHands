extends Node2D

class_name Wand

signal on_cooldown_changed(cooldown: float)

var _wand_data: WandData

@onready var shooting_sound = $ShootingSound
@onready var shooting_point = %ShootingPoint
@onready var sprite = %Sprite

var last_shot: float = 0.0
var cooldown: float = 0.0

func _ready() -> void:
	if _wand_data != null:
		sprite.texture = _wand_data.wand_sprite
		shooting_point.position = _wand_data.shooting_point_offset

func _process(_delta: float) -> void:
	if cooldown > 0.0:
		cooldown = last_shot + _wand_data.cooldown_ms - Time.get_ticks_msec()
		on_cooldown_changed.emit(cooldown)


func set_data(new_wand_data: WandData) -> void:
	_wand_data = new_wand_data

func shoot():
	if cooldown > 0.0:
		return
	
	last_shot = Time.get_ticks_msec()
	cooldown = _wand_data.cooldown_ms
	shooting_sound.play()
	var projectile: Projectile = _wand_data.projectile_prefab.instantiate()
	projectile.init(_wand_data.projectile_speed, _wand_data.projectile_range, _wand_data.damage)
	projectile.global_transform = shooting_point.global_transform
	get_tree().current_scene.add_child(projectile)
