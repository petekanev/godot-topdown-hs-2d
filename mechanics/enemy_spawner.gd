extends Node2D

@export var enemy_scene: PackedScene

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

const SPEED: int = 100

func get_enemy_instance(spawn_position: Vector2, target_position: Vector2) -> Node2D:
	var enemy_instance = enemy_scene.instantiate()

	enemy_instance.position = spawn_position
	
	enemy_instance.set_target_position(target_position)

	return enemy_instance