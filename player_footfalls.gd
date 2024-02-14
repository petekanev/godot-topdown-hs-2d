extends AnimatedSprite2D


# Called when the node enters the scene tree for the first time.
func _ready():
	autoplay = "default"


func _on_animation_finished():
	queue_free()


# in case we forget the animation as autoplayable
func _on_animation_looped():
	visible = false
	queue_free()
