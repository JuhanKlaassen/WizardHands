extends Node2D


func play_walk():
	%AnimationPlayer.play("walk")
	#this dumbass mouse outputs collision (and animations) based on an unmovable anchor misalligned with the sprite
	#bruh

func play_hurt():
	%AnimationPlayer.play("hurt")
	%AnimationPlayer.queue("walk")
