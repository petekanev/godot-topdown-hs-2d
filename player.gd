extends CharacterBody2D


@export var SPEED = 300.0
@export var MAP_BOUNDS = Vector2(1920*2, 1080*2)

var footfalls = preload("res://player_footfalls.tscn")
var projectile = preload("res://player_projectile.tscn")

var walking_left: bool = false
var walking_up: bool = false
var is_attacking: bool = false
var attack_direction: Vector2 = Vector2()

var footfalls_rate: float = 0.3
var footfalls_distance_behind = 15
var can_cast_footfalls = true

var projectile_fire_rate: float = 0.4
var projectile_origin_offset = 30
var can_fire_projectile = true


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
		
		# if walking horizontally, offset the footfall to be lower relative to the player
		if input_direction.x != 0:
			footfalls_instance.position.y += 10
		
		if can_cast_footfalls:
			get_tree().get_root().add_child(footfalls_instance)
			can_cast_footfalls = false
			await get_tree().create_timer(footfalls_rate).timeout
			can_cast_footfalls = true
			
		$AnimatedSprite2D.animation = animation
	else:
		$AnimatedSprite2D.animation = "idle"

func animate_attacks():
	if is_attacking:
		var animation = "attacking"
		var attacking_left = attack_direction.x < 0
		var attacking_up = attack_direction.y < 0
		var attacking_down = attack_direction.y > 0
		
		# player is facing left
		$AnimatedSprite2D.flip_h = attacking_left
		if attacking_up:
			animation = "attacking_up"
		elif attacking_down:
			animation = "attacking_down"
		
		$AnimatedSprite2D.animation = animation

func _ready():
	$AnimatedSprite2D.animation = "idle"
	$AnimatedSprite2D.play()

func _process(delta):
	if Input.is_action_pressed("Shoot") and can_fire_projectile:
		is_attacking = true

		var mouse_position = get_global_mouse_position()
		var projectile_instance = projectile.instantiate() as RigidBody2D
		
		var direction = global_position.direction_to(mouse_position)
		attack_direction = direction
		projectile_instance.look_at(direction)
		
		# the position of origin should be offset from the position of the player
		projectile_instance.position = global_position
		projectile_instance.position.x += direction.x * projectile_origin_offset
		projectile_instance.position.y += direction.y * projectile_origin_offset
		
		var proj_rotation = direction.angle()
		projectile_instance.apply_impulse(Vector2(1000, 0).rotated(proj_rotation), Vector2.ZERO)
		get_tree().get_root().add_child(projectile_instance)

		can_fire_projectile = false
		await get_tree().create_timer(projectile_fire_rate).timeout
		can_fire_projectile = true
	else:
		if is_attacking:
			# "stop" attacking to allow the animation to run
			await get_tree().create_timer(1).timeout
			prints("reset is_attacking")
			is_attacking = false
	
	# animate
	animate_movement()
	animate_attacks()

func _physics_process(delta):
	# move
	process_directional_input()
	move_and_slide()
	# clamp position to be within world bounds
	position = position.clamp(Vector2.ZERO, MAP_BOUNDS)
	
	
