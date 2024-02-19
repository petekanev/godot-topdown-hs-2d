extends Node2D


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func _on_enemy_timer_timeout():
	var enemy_spawn_location = $EnemySpawnPath/PathFollow2D
	enemy_spawn_location.progress_ratio = randf()

	var player_location = $Player.position

	var enemy_node = $EnemySpawner.get_enemy_instance(enemy_spawn_location.position, player_location)
	add_child(enemy_node)


func _on_game_audio_loop_finished():
	$GameAudioLoop.play()
