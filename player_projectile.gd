extends RigidBody2D

var explosion = preload("res://projectile_explosion.tscn")

func _on_body_entered(body):
	if !body.is_in_group("player"):
		var explosion_instance = explosion.instantiate()
		explosion_instance.position = get_global_position()
		get_tree().get_root().add_child(explosion_instance)

		queue_free()
