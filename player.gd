extends CharacterBody2D


const SPEED = 300.0
const MAP_BOUNDS = Vector2(1920*2, 1080*2)

var walking_left: bool = false
var walking_up: bool = false

func process_directional_input():
	var input_direction = Input.get_vector("Left", "Right", "Up", "Down")
	velocity = input_direction * SPEED

func animate_movement():
	var animation = "walking"
	if velocity.length() != 0:
		walking_left = velocity.x < 0
		walking_up = velocity.y < 0
		var walking_down = velocity.y > 0
		
		$AnimatedSprite2D.flip_h = walking_left

		if walking_up:
			animation = "walking_up"
		elif walking_down:
			animation = "walking_down"
			
		$AnimatedSprite2D.animation = animation
	else:
		$AnimatedSprite2D.animation = "idle"

func _ready():
	$AnimatedSprite2D.animation = "idle"
	$AnimatedSprite2D.play()

func _physics_process(delta):
	# move
	process_directional_input()
	move_and_slide()
	# clamp position to be within world bounds
	position = position.clamp(Vector2.ZERO, MAP_BOUNDS)

	# animate
	animate_movement()
