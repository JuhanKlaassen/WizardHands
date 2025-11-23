extends Node2D
class_name Waves

var wave_active := false

# enemy scenes
const ENEMY_SCENES = {
	"mob": preload("res://Prefabs/mob.tscn"),
	"mob2": preload("res://Prefabs/mob2.tscn")
}
# I must clean up this script and enemies very soon
# wave data
const WAVES = [
	{
		"count": 10,
		"spawn_rate": 1.0,
		"enemies": ["mob"]
	},
	{
		"count": 20,
		"spawn_rate": 0.9,
		"enemies": ["mob", "mob2"]
	},
	{
		"count": 30,
		"spawn_rate": 0.75,
		"enemies": ["mob", "mob2"],
		"spawn_special_at_end": {
			"type": "mob2",
			"health_mult": 4.0,
			"scale_mult": 1.6,
			"speed_mult": 0.8
		}
	}
]

var current_wave := 0
var display_wave_count := 1  # shows the real wave number
var enemies_to_spawn := 0
var spawn_timer := 0.0

func start_waves():
	wave_active = true
	load_wave(current_wave)

func load_wave(index):
	# if the index is beyond defined waves, lock to last wave (temporary for now)
	if index >= WAVES.size():
		index = WAVES.size() - 1

	var w = WAVES[index]
	# optional - scale enemy count for repeated waves
	#if display_wave_count > WAVES.size():
	#	enemies_to_spawn = int(w["count"] * (display_wave_count / WAVES.size()))
	#else:
	enemies_to_spawn = w["count"]

	spawn_timer = 0.0

	print("Starting wave ", display_wave_count)

func process_wave(delta):
	if enemies_to_spawn <= 0:
		return

	spawn_timer -= delta

	if spawn_timer <= 0:
		spawn_enemy()
		enemies_to_spawn -= 1

		var rate = WAVES[current_wave]["spawn_rate"]
		spawn_timer = rate

func spawn_enemy():
	var wave_data = WAVES[current_wave]
	var enemy_type = wave_data["enemies"].pick_random()
	var scene = ENEMY_SCENES[enemy_type]

	%PathFollow2D.progress_ratio = randf()
	var enemy = scene.instantiate()
	enemy.global_position = %PathFollow2D.global_position
	add_child(enemy)

func spawn_enemy_with_modifiers(enemy_type: String, modifiers := {}):
	var scene = ENEMY_SCENES[enemy_type]

	%PathFollow2D.progress_ratio = randf()
	var enemy = scene.instantiate()
	enemy.global_position = %PathFollow2D.global_position
	
	# Apply modifiers if present
	if modifiers.has("health_mult"):
		enemy.health *= modifiers["health_mult"]

	if modifiers.has("scale_mult"):
		enemy.scale *= Vector2.ONE * modifiers["scale_mult"]

	if modifiers.has("speed_mult"):
		enemy.speed *= modifiers["speed_mult"]

	add_child(enemy)
	return enemy

func next_wave():
	
	# If current wave has a special enemy, spawn it
	var wave_data = WAVES[current_wave]
	if wave_data.has("spawn_special_at_end"):
		var sp = wave_data["spawn_special_at_end"]
		spawn_enemy_with_modifiers(
			sp["type"],
			sp
		)
	
	current_wave += 1
	display_wave_count += 1  # increment the visible wave number (I'll remove this soon)

	# lock current_wave to the last wave if exceeded (temporary fo' now)
	if current_wave >= WAVES.size():
		current_wave = WAVES.size() - 1

	load_wave(current_wave)
