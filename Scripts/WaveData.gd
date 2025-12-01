extends Resource
class_name WaveData

@export var count: int
@export var spawn_rate: float
@export var enemies: Array[String]
@export var spawn_special_at_end: Dictionary

# enemy scaling values
@export var health_scale_per_wave := 0.10 # +10% per wave
@export var speed_scale_per_wave := 0.05 # +5% per waveS
@export var size_scale_per_wave := 0.03 # +3% per wave (little point to this, but...)
