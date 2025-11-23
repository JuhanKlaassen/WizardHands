extends Node2D


class_name Wand

var _wand_data: WandData


@onready var shooting_sound = $ShootingSound
@onready var shooting_point = %ShootingPoint
@onready var sprite = %Sprite

func set_data(new_wand_data: WandData) -> void:
	_wand_data = new_wand_data
	new_wand_data.wand_instance = self

func _ready() -> void:
	if _wand_data != null:
		sprite.texture = _wand_data.wand_sprite
		shooting_point.position = _wand_data.shooting_point_offset

func shoot():
	shooting_sound.play()
	var projectile: Projectile = _wand_data.projectile_prefab.instantiate()
	projectile.init(_wand_data.projectile_speed, _wand_data.projectile_range, _wand_data.damage)
	projectile.global_transform = shooting_point.global_transform
	get_tree().current_scene.add_child(projectile)
