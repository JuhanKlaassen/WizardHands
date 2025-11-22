extends Resource

class_name ItemData

@export var name: String
@export var description: String;
@export var icon: AtlasTexture
@export var max_stack: int = 1

var is_stackable: bool:
	get:
		return max_stack > 1