extends Node2D
class_name Waves


# Runtime variables
var entitySpawn := 0
var wave_active := false
var between_waves := false
var delay_timer := 0.0
var current_wave := 0
var display_wave_count := 1
var enemies_to_spawn := 0
var spawn_timer := 0.0

# Constants
const WAVE_DELAY = 3.0 # seconds between waves

# enemy scaling settings per wave
@export var health_per_wave := 1.15
@export var speed_per_wave := 1.05
@export var scale_per_wave := 1.02

# resources
@export var wave_collection: WaveCollection

@onready var wave_label = $"/root/Game/UI/WaveLabel"
@onready var difficulty_label = $"/root/Game/UI/DifficultyScalingLabel"

func _ready():
	start_wave()

func start_wave():
	wave_label.text = "Wave " + str(display_wave_count)
	wave_label.visible = true
	
	var diff = get_current_difficulty_multiplier()
	difficulty_label.text = "Enemy difficulty scale x" + str(round(diff * 100) / 100.0)
	difficulty_label.visible = true
	
	# show label for some seconds
	delay_timer = WAVE_DELAY
	between_waves = true

func start_waves():
	wave_active = true
	load_wave(current_wave)

func load_wave(index):
	if not wave_collection:
		push_error("No WaveCollection resource loaded!")
		return
	
	# if the index is beyond defined waves, lock to last wave
	if index >= wave_collection.waves.size():
		index = wave_collection.waves.size() - 1

	var w = wave_collection.waves[index]
	enemies_to_spawn = w.count
	spawn_timer = 0.0

	print("Starting wave ", display_wave_count)

func process_wave(delta):
	if enemies_to_spawn <= 0:
		return

	spawn_timer -= delta

	if spawn_timer <= 0:
		spawn_random_enemy()
		enemies_to_spawn -= 1

		var rate = wave_collection.waves[current_wave].spawn_rate
		spawn_timer = rate

func spawn_random_enemy():
	if not wave_collection or wave_collection.waves.is_empty():
		push_error("Resources not loaded for spawning!")
		return
	
	var wave_data = wave_collection.waves[current_wave]
	var enemy_data = wave_data.enemies.pick_random()
	spawn_enemy(enemy_data)

func next_wave():
	if not wave_collection or wave_collection.waves.is_empty():
		push_error("No WaveCollection resource loaded or no waves!")
		return
	
	# if current wave has a special enemy, spawn it
	var wave_data = wave_collection.waves[current_wave]
	
	if wave_data.spawn_special_at_end != null:
		spawn_enemy(wave_data.spawn_special_at_end)
	
	current_wave += 1
	display_wave_count += 1

	# lock current_wave to the last wave if exceeded
	if current_wave >= wave_collection.waves.size():
		current_wave = wave_collection.waves.size() - 1

	load_wave(current_wave)

func apply_wave_scaling(enemy: Enemy):
	var wave_multiplier = float(current_wave)
	var difficulty_multiplier = get_current_difficulty_multiplier()
	
	# health scaling
	if "health" in enemy:
		var multiplier = pow(health_per_wave, wave_multiplier)
		enemy.health *= multiplier
		enemy.max_health *= multiplier

	# speed scaling
	if "speed" in enemy:
		enemy.speed *= pow(speed_per_wave, wave_multiplier)
	
	if "xp" in enemy:
		enemy.xp = int(enemy.xp * difficulty_multiplier)

	# size scaling
	enemy.scale *= Vector2.ONE * pow(scale_per_wave, wave_multiplier)

func get_current_difficulty_multiplier() -> float:
	var wave = float(current_wave)
	var h_mult = pow(health_per_wave, wave)
	var s_mult = pow(speed_per_wave, wave)
	var sc_mult = pow(scale_per_wave, wave)

	# shown difficulty multiplier
	return (h_mult + s_mult) / 2.0

func _process(delta):
	if between_waves:
		delay_timer -= delta
		if delay_timer <= 0:
			wave_label.visible = false
			between_waves = false
			start_waves() # load first wave or continue waves
		return

	process_wave(delta)

	if enemies_to_spawn <= 0 and not between_waves:
		next_wave()
		start_wave()

func spawn_enemy(enemy_data: EnemyData):
	%PathFollow2D.progress_ratio = randf()
	var scene = Enemy.new_enemy(enemy_data)
	scene.global_position = %PathFollow2D.global_position
	
	# enemy scaling
	apply_wave_scaling(scene)
	
	get_parent().add_child(scene)
