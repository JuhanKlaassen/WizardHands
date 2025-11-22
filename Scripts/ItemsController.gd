extends Node

@export var ground_item_scene: PackedScene

func spawn(item_data: ItemData, amount: int, position: Vector2) -> void:
	var already_spawned: int = 0
	while already_spawned < amount:
		var amount_to_spawn: int
		if amount > item_data.max_stack:
			amount_to_spawn = item_data.max_stack
		else:
			amount_to_spawn = amount
		already_spawned += amount_to_spawn


		var ground_item: GroundItem = ground_item_scene.instantiate()
		ground_item.position = position
		ground_item.set_item(Item.new(item_data, amount_to_spawn))

		call_deferred("add_child", ground_item)
