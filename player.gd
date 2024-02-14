extends CharacterBody2D


@export var SPEED = 300.0
@export var MAP_BOUNDS = Vector2(1920*2, 1080*2)

var footfalls = preload("res://player_footfalls.tscn")

var walking_left: bool = false
var walking_up: bool = false

var footfalls_rate: float = 0.3
var footfalls_distance_behind = 15
var can_cast_footfalls = true

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
			
		var input_direction = Input.get_vector("Left", "Right", "Up", "Down")
		var footfalls_instance = footfalls.instantiate()
		footfalls_instance.position = global_position
		footfalls_instance.position.x -= input_direction.x * footfalls_distance_behind
		footfalls_instance.position.y -= input_direction.y * footfalls_distance_behind
		
		# if walking horizontally, offset the footfall to be lower
		if input_direction.x != 0:
			footfalls_instance.position.y += 15
		
		if can_cast_footfalls:
			get_tree().get_root().add_child(footfalls_instance)
			can_cast_footfalls = false
			await get_tree().create_timer(footfalls_rate).timeout
			can_cast_footfalls = true
			
		$AnimatedSprite2D.animation = animation
	else:
		$AnimatedSprite2D.animation = "idle"


func _ready():
	$AnimatedSprite2D.animation = "idle"
	$AnimatedSprite2D.play()

func _process(delta):
	# animate
	animate_movement()

func _physics_process(delta):
	# move
	process_directional_input()
	move_and_slide()
	# clamp position to be within world bounds
	position = position.clamp(Vector2.ZERO, MAP_BOUNDS)
	
	
