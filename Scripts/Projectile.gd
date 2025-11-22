extends Area2D

class_name Projectile

var travelled_distance = 0

var _speed: int = 1000
var _range: int = 1200
var _damage: int = 1

func init(speed: int, range: int, damage: int) -> void:
	_speed = speed
	_range = range
	_damage = damage
	pass

func _physics_process(delta):
	position += Vector2.RIGHT.rotated(rotation) * _speed * delta
	
	travelled_distance += _speed * delta
	if travelled_distance > _range:
		queue_free()


func _on_body_entered(body):
	queue_free()
	if body.has_method("take_damage"):
		body.take_damage(_damage)
