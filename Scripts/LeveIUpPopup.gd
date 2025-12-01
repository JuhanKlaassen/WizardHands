extends RichTextLabel

@export var float_speed: float = 50.0
@export var duration: float = 1.5

var _time_passed: float = 0.0

func _process(delta):
	position.y -= float_speed * delta
	_time_passed += delta
	if _time_passed >= duration:
		queue_free()
