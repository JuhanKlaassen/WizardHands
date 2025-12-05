extends ItemData

class_name WandData

@export var base_damage: int = 1
@export var base_cooldown_ms: int = 1000
@export var base_projectile_speed: int = 1000
@export var base_projectile_range: int = 1200
@export var base_mana_cost: int = 1
@export var modifier_slot_count: int = 1
@export var projectile_prefab: PackedScene
@export var wand_sprite: Texture
@export var shooting_point_offset: Vector2 = Vector2(51.0, -12.0)

var modifiers: Array[WandModifier] = []
