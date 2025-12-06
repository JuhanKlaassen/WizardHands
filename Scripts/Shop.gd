extends Node2D

@export var offer_collection: ShopCollection
@export var stands: Array[ShopStand]

func _ready() -> void:
	var offers = get_random_offers()
	for i in range(stands.size()):
		if offers.keys()[i] != null:
			stands[i].set_offer(offers.keys()[i], offers.values()[i])

func get_random_offers() -> Dictionary:
	var keys = offer_collection.offers.keys()
	keys.shuffle()
	
	var result = {}
	var limit = min(stands.size(), keys.size())
	
	for i in range(limit):
		var key = keys[i]
		result[key] = offer_collection.offers[key]
	
	return result
