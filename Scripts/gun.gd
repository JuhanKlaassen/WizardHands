extends Area2D

@onready var shooting_point = %ShootingPoint
const BULLET = preload("res://Prefabs/bullet_2d.tscn")

func _process(_delta):
	# Rotate to face the mouse position
	var mouse_pos = get_global_mouse_position()
	look_at(mouse_pos)

	# If left mouse button is pressed, shoot
	if Input.is_action_just_pressed("shoot"):
		shoot()


func shoot():
	var new_bullet = BULLET.instantiate()
	new_bullet.global_transform = shooting_point.global_transform
	get_tree().current_scene.add_child(new_bullet)
