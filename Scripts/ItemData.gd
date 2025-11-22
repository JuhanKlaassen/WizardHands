extends Resource

class_name ItemData

enum ItemType {
	UNSET,
	WAND,
}

@export var name: String
@export var description: String;
@export var icon: AtlasTexture
@export var max_stack: int = 1
@export var item_type: ItemType = ItemType.UNSET

var is_stackable: bool:
	get:
		return max_stack > 1