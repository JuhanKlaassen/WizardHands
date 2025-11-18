extends Node2D

var entitySpawn := 0

func spawn_mob():
	%PathFollow2D.progress_ratio = randf()
	var new_mob = preload("res://Prefabs/mob.tscn").instantiate()
	new_mob.global_position = %PathFollow2D.global_position
	add_child(new_mob)

func spawn_mob2():
	%PathFollow2D.progress_ratio = randf()
	var new_mob2 = preload("res://Prefabs/mob2.tscn").instantiate()
	new_mob2.global_position = %PathFollow2D.global_position
	add_child(new_mob2)

func _on_timer_timeout():
	match entitySpawn:
		0:
			spawn_mob()
			entitySpawn = 1
		1:
			spawn_mob2()
			entitySpawn = 0
