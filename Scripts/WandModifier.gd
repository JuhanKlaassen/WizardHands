extends ItemData

class_name WandModifier

enum WandModifierType {
    DAMAGE,
    COOLDOWN,
    PROJECTILE_SPEED,
    RANGE,
}

@export var modifier_type: WandModifierType
@export var value: float

func apply(wand: Wand) -> void:
    match modifier_type:
        WandModifierType.DAMAGE:
            wand.damage += value
        WandModifierType.COOLDOWN:
            wand.cooldown_ms += value
        WandModifierType.PROJECTILE_SPEED:
            wand.projectile_speed += value
        WandModifierType.RANGE:
            wand.projectile_range += value