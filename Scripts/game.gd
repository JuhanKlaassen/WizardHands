extends Node2D

var entitySpawn := 0
	
func spawn_mob():
	%PathFollow2D.progress_ratio = randf()
	var new_mob = preload("res://Prefabs/mob.tscn").instantiate()
	new_mob.global_position = %PathFollow2D.global_position
	add_child(new_mob)

@onready var waves = $Waves
@onready var wave_label = $"/root/Game/UI/WaveLabel"

var between_waves := false
var delay_timer := 0.0
const WAVE_DELAY = 3.0   # seconds between waves


func _ready():
	start_wave()

func start_wave():
	wave_label.text = "Wave " + str(waves.current_wave + 1)
	wave_label.visible = true

	# show label for some seconds
	delay_timer = WAVE_DELAY
	between_waves = true

func _process(delta):
	if between_waves:
		delay_timer -= delta
		if delay_timer <= 0:
			wave_label.visible = false
			between_waves = false
			waves.start_waves()   # load first wave or continue waves
		return

	waves.process_wave(delta)

	if waves.enemies_to_spawn <= 0 and not between_waves:
		waves.next_wave()
		start_wave()
