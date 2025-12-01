extends Projectile

class_name Splash

@export var _explosion_radius: float = 1000.0

func _physics_process(delta):
	position += Vector2.RIGHT.rotated(rotation) * _speed * delta
	
	travelled_distance += _speed * delta
	if travelled_distance > _range:
		var entities_in_radius = get_collisions_in_circle(global_position, _explosion_radius)
		for entity in entities_in_radius:
			if entity.collider.has_method("take_damage"):
				entity.collider.take_damage(_damage)
		queue_free()


func _on_body_entered(body):
	var entities_in_radius = get_collisions_in_circle(global_position, _explosion_radius)
	for entity in entities_in_radius:
		if entity.collider.has_method("take_damage"):
			entity.collider.take_damage(_damage)
	queue_free()

func get_collisions_in_circle(center: Vector2, radius: float) -> Array:
	var shape_cast = ShapeCast2D.new()
	shape_cast.shape = CircleShape2D.new()
	shape_cast.shape.radius = radius
	shape_cast.target_position = Vector2.ZERO
	shape_cast.collision_mask = 0b00000000_00000000_00000000_00010000 # Adjust as needed

	add_child(shape_cast)
	shape_cast.global_position = center
	shape_cast.force_shapecast_update()

	var results = []
	var collision_count = shape_cast.get_collision_count()
	for i in range(collision_count):
		results.append({
			"collider": shape_cast.get_collider(i),
			"point": shape_cast.get_collision_point(i),
			"normal": shape_cast.get_collision_normal(i)
		})

	shape_cast.queue_free()
	return results