extends Resource

class_name PlayerModifier

enum PlayerModifierType {
    HEALTH,
    HEALTH_REGEN,
    MANA,
    MANA_REGEN,
    SPEED,
    DODGE
}

enum PlayerModifierValue {
    ADD,
    MULTIPLY,
}

@export var name: String
@export var type: PlayerModifierType
@export var value_type: PlayerModifierValue
@export var value: float

func apply(player: Player) -> void:
    match type:
        PlayerModifierType.HEALTH:
            if player.health == player.max_health:
                player.health += value
            player.max_health += value
            player.on_heal.emit()
        PlayerModifierType.HEALTH_REGEN:
            player.health_regen_per_second += value
        PlayerModifierType.MANA:
            if player.mana == player.max_mana:
                player.mana += value
            player.max_mana += value
            player.on_mana_changed.emit()
        PlayerModifierType.MANA_REGEN:
            player.mana_regen += value
        PlayerModifierType.SPEED:
            player.speed += value
        PlayerModifierType.DODGE:
            player.dodge += value