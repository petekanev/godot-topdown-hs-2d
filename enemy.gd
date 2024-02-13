extends CharacterBody2D

@onready var player := $"../Player"

const SPEED = 300.0
var walking_left: bool = false

func animate_movement():
	var animation = "walking"
	if velocity.length() != 0:
		walking_left = velocity.x < 0
		
		$AnimatedSprite2D.flip_h = walking_left

		$AnimatedSprite2D.animation = animation
	else:
		$AnimatedSprite2D.animation = "idle"

func _ready():
	$AnimatedSprite2D.animation = "idle"
	$AnimatedSprite2D.play()

func _physics_process(delta):
	move_and_slide()
	
	# animate
	animate_movement()
