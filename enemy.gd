extends CharacterBody2D

@onready var player := $"../Player"
@onready var nav_agent := $NavigationAgent2D

const SPEED = 100.0
var walking_left: bool = false
var _next_velocity := Vector2.ZERO

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
	
	nav_agent.connect("velocity_computed", Callable(self, "move"))

func _physics_process(delta):
	# navigation is never finished - always follow the player
	#if nav_agent.is_navigation_finished():
		#return
	
	nav_agent.target_position = player.position
	var next_target_position = nav_agent.get_next_path_position()

	var next_direction = position.direction_to(next_target_position)

	_next_velocity = next_direction * SPEED
	nav_agent.velocity = _next_velocity

	# animate
	animate_movement()

func move(computed_velocity: Vector2):
	velocity = computed_velocity
	
	move_and_slide()

