extends Resource
class_name EnemyScenes

@export var mob: PackedScene
@export var mob2: PackedScene

func get_scene(enemy_type: String) -> PackedScene:
	match enemy_type:
		"mob":
			return mob
		"mob2":
			return mob2
		_:
			return null
