extends Resource

class_name EnemyData

@export var speed: int = 250
@export var health: int = 3
@export var health_regen_per_second: float = 0.0
@export var damage: int = 1
@export var damage_cooldown_ms: int = 1000
@export var xp: int = 30
@export var enemy_scene: PackedScene
@export_group("Extra scene data")
@export var look_at: bool = false
@export var offset: Vector2
@export_range(-360.0, 360.0) var rotation: float
@export var scale: Vector2
