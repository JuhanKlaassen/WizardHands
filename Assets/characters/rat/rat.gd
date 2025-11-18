extends Node2D


func play_walk():
	%AnimationPlayer.play("walk")

func play_hurt():
	%AnimationPlayer.play("hurt")
	await get_tree().create_timer(0.5).timeout
	%AnimationPlayer.stop()
