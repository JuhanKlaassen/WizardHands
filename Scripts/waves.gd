extends Node2D
class_name Waves

# Preload resource classes
@warning_ignore("shadowed_global_identifier")
const WaveData = preload("res://Resources/Waves/wave_data_resource.gd")
@warning_ignore("shadowed_global_identifier")
const WaveCollection = preload("res://Resources/Waves/wave_collection_resource.gd")
@warning_ignore("shadowed_global_identifier")
const EnemyScenes = preload("res://Resources/Waves/enemy_scenes_resource.gd")

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
const WAVE_DELAY = 3.0   # seconds between waves

# enemy scaling settings per wave
@export var health_per_wave := 1.15
@export var speed_per_wave := 1.05
@export var scale_per_wave := 1.02

# resources
@export var wave_collection: WaveCollection
@export var enemy_scenes: EnemyScenes

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
		spawn_enemy()
		enemies_to_spawn -= 1

		var rate = wave_collection.waves[current_wave].spawn_rate
		spawn_timer = rate

func spawn_enemy():
	if not wave_collection or not enemy_scenes or wave_collection.waves.is_empty():
		push_error("Resources not loaded for spawning!")
		return
	
	var wave_data = wave_collection.waves[current_wave]
	var enemy_type = wave_data.enemies.pick_random()
	var scene = enemy_scenes.get_scene(enemy_type)

	if not scene:
		push_error("No scene found for enemy type: ", enemy_type)
		return

	%PathFollow2D.progress_ratio = randf()
	var enemy = scene.instantiate()
	enemy.global_position = %PathFollow2D.global_position
	
	# enemy scaling
	apply_wave_scaling(enemy)
	
	get_parent().add_child(enemy)

func spawn_enemy_with_modifiers(enemy_type: String, modifiers := {}):
	if not enemy_scenes:
		push_error("EnemyScenes resource not loaded!")
		return null
	
	var scene = enemy_scenes.get_scene(enemy_type)
	if not scene:
		push_error("No scene found for enemy type: ", enemy_type)
		return null

	%PathFollow2D.progress_ratio = randf()
	var enemy = scene.instantiate()
	enemy.global_position = %PathFollow2D.global_position

	if modifiers.has("health_mult"):
		enemy.health *= modifiers["health_mult"]

	if modifiers.has("scale_mult"):
		enemy.scale *= Vector2.ONE * modifiers["scale_mult"]

	if modifiers.has("speed_mult"):
		enemy.speed *= modifiers["speed_mult"]
	
	# enemy scaling
	apply_wave_scaling(enemy)
	
	get_parent().add_child(enemy)
	return enemy

func next_wave():
	if not wave_collection or wave_collection.waves.is_empty():
		push_error("No WaveCollection resource loaded or no waves!")
		return
	
	# if current wave has a special enemy, spawn it
	var wave_data = wave_collection.waves[current_wave]
	
	if wave_data.get("spawn_special_at_end"):
		var sp = wave_data.spawn_special_at_end
		var enemy_type = sp.get("type", "mob")  # default to "mob" if not found
		spawn_enemy_with_modifiers(enemy_type, sp)
	
	current_wave += 1
	display_wave_count += 1

	# lock current_wave to the last wave if exceeded
	if current_wave >= wave_collection.waves.size():
		current_wave = wave_collection.waves.size() - 1

	load_wave(current_wave)

func apply_wave_scaling(enemy):
	var wave_multiplier = float(current_wave)

	# health scaling
	if "health" in enemy:
		enemy.health *= pow(health_per_wave, wave_multiplier)

	# speed scaling
	if "speed" in enemy:
		enemy.speed *= pow(speed_per_wave, wave_multiplier)

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
			start_waves()   # load first wave or continue waves
		return

	process_wave(delta)

	if enemies_to_spawn <= 0 and not between_waves:
		next_wave()
		start_wave()
