extends ItemData

class_name WandData

@export var damage: int = 1
@export var projectile_speed: int = 1000
@export var projectile_range: int = 1200
@export var projectile_prefab: PackedScene
@export var wand_sprite: Texture
@export var shooting_point_offset: Vector2 = Vector2(51.0, -12.0)

var wand_instance: Wand

func action(item: Item, player: Player, mouse_pos: Vector2) -> void:
    if wand_instance == null:
        return

    wand_instance.shoot()