extends CharacterBody2D

@onready var player := $"../Player"
@onready var nav_agent := $NavigationAgent2D

const SPEED = 100.0
var walking_left: bool = false

func set_target_position(target: Vector2):
	$NavigationAgent2D.target_position = target

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
	nav_agent.target_position = player.position

	var next_direction = position.direction_to(nav_agent.get_next_path_position())

	velocity = next_direction * SPEED
	nav_agent.set_velocity_forced(velocity)

	#emit_signal("path_changed", [])
	#prints('pos:', position, 'target pos:', nav_agent.target_position, 'next:', next_direction, 'velocity:', velocity)
	#prints(nav_agent.get_final_position(), nav_agent.is_navigation_finished(), nav_agent.is_target_reachable())

	move_and_slide()
	
	# animate
	animate_movement()

