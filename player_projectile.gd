class_name PlayerProjectile extends RigidBody2D

var PROJECTILE_LIFETIME_SECONDS: float = 1.5
const PROJECTILE_DECAY_INTERVAL: float = 0.1
const PROJECTILE_DECAY_STEP := Vector2(0.05, 0.05)

var explosion = preload("res://projectile_explosion.tscn")

@onready var decay_timer := $DecayTimer as Timer

var projectile_scale := Vector2(1.0, 1.0)

# defines who emited the projectile - player or enemy object
# in this case as a player_projectile - we can assume it's the player
var origin: Character


func _ready():
	expire_projectile()

	decay_timer.timeout.connect(decay_projectile)
	decay_timer.start(PROJECTILE_DECAY_INTERVAL)


func _process(delta):
	scale = projectile_scale


func _on_body_entered(body: Node2D):
	if !body.is_in_group("player"):
		explode_projectile()
		
		if body.is_in_group("enemy"):
			var character = body as Character
			character.on_hit_by_character(origin)

		queue_free()


func explode_projectile():
	var explosion_instance = explosion.instantiate()
	explosion_instance.position = get_global_position()
	get_tree().get_root().add_child(explosion_instance)

	queue_free()


func expire_projectile():
	await get_tree().create_timer(PROJECTILE_LIFETIME_SECONDS).timeout
	explode_projectile()
	queue_free()


func decay_projectile():
	if projectile_scale.x > 0:
		projectile_scale = projectile_scale - PROJECTILE_DECAY_STEP


