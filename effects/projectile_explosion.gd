extends Area2D

@onready var animated_sprite := $AnimatedSprite2D as AnimatedSprite2D

# defines who emited the projectile - player or enemy object
var origin: Character
# bodies to ignore registering the hit for
var excluded_bodies = []


func _ready():
	animated_sprite.play("default")


func _on_animated_sprite_animation_finished():
	queue_free()


# splash damage
func _on_body_entered(body):
	if body.is_in_group("enemy"):
		var character = body as Character
		var ignore_hit := false
		
		for excluded_body in excluded_bodies:
			if excluded_body and body == excluded_body:
				ignore_hit = true

		if !ignore_hit:
			character.on_hit_by_character(origin)

