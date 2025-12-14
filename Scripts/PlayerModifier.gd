extends Resource

class_name PlayerModifier

enum PlayerModifierType {
	HEALTH, HEALTH_REGEN,
	MANA, MANA_REGEN,
	SPEED, DODGE,
	MOREXP, MOREGOLD,
	MORELUCK
}
#shield #armour #random stat
enum PlayerModifierValue {
	ADD,
	MULTIPLY,
}

@export var name: String
@export var type: PlayerModifierType
@export var value_type: PlayerModifierValue
@export var value1: float
@export var value2: float
@export var value3: float

var final_value: float = 0.0  # runtime only, not exported


func apply(player: Player, amount: float) -> void:
	match type:
		PlayerModifierType.HEALTH:
			if player.health == player.max_health:
				player.health += amount
			player.max_health += amount
			player.on_heal.emit()
		PlayerModifierType.HEALTH_REGEN:
			player.health_regen_per_second += amount
		PlayerModifierType.MANA:
			if player.mana == player.max_mana:
				player.mana += amount
			player.max_mana += amount
			player.on_mana_changed.emit()
		PlayerModifierType.MANA_REGEN:
			player.mana_regen += amount
		PlayerModifierType.SPEED:
			player.speed += amount
		PlayerModifierType.DODGE:
			player.dodge += amount
		PlayerModifierType.MOREXP:
			player.more_xp += amount
		PlayerModifierType.MOREGOLD:
			player.more_gold += amount
		PlayerModifierType.MORELUCK:
			player.luck += amount
