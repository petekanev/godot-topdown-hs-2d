class_name Player extends Character

@export var MAP_BOUNDS = Vector2(1920*2, 1080*2)

const ATTACK_DMG_MIN: int = 15
const ATTACK_DMG_MAX: int = 25
const ATTACK_CRIT_CHANCE: int = 5
const ATTACK_RATE: float = 0.4
const EXP_PER_LEVEL_BASE: int = 15

const HEALTH_MAX = 100

const SPEED = 300.0

var footfalls = preload("res://effects/player_footfalls.tscn")
var projectile = preload("res://effects/player_projectile.tscn")

@onready var animated_sprite := $AnimatedSprite2D as AnimatedSprite2D

@onready var attack_audio_player := $Sounds/AttackSound as AudioStreamPlayer
@onready var footsteps_audio_player := $Sounds/FootstepSounds as AudioStreamPlayer
@onready var injured_audio_player := $Sounds/InjuredSounds as AudioStreamPlayer

var walking_left: bool = false
var walking_up: bool = false
var is_attacking: bool = false
var attack_direction: Vector2 = Vector2()

var footfalls_rate: float = 0.3
var footfalls_distance_behind = 15
var can_cast_footfalls = true

var projectile_origin_offset = 30
var can_fire_projectile = true


func process_directional_input():
	var input_direction = Input.get_vector("Left", "Right", "Up", "Down")
	velocity = input_direction * SPEED


func animate_footfalls():
	if velocity.length() != 0:
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
			await get_tree().create_timer(footfalls_rate, false).timeout
			can_cast_footfalls = true


func get_next_animation() -> String:
	var animation = "idle"
	var is_moving = velocity.length() != 0

	if is_attacking:
		animation = "attacking"
		# the character is facing more left or right than up or down
		var is_horizontally_aligned = abs(attack_direction.x) > abs(attack_direction.y)
		var attacking_left = attack_direction.x < 0
		var attacking_up = !is_horizontally_aligned and attack_direction.y < 0
		var attacking_down = !is_horizontally_aligned and attack_direction.y > 0
		
		# player is facing left
		$AnimatedSprite2D.flip_h = attacking_left
		if attacking_up:
			animation = "attacking_up"
		elif attacking_down:
			animation = "attacking_down"
	elif is_moving:
		animation = "walking"
		walking_left = velocity.x < 0
		walking_up = velocity.y < 0
		var walking_down = velocity.y > 0
		
		$AnimatedSprite2D.flip_h = walking_left
		if walking_up:
			animation = "walking_up"
		elif walking_down:
			animation = "walking_down"
		
	return animation


func animate_movement():
	var animation = get_next_animation()
	if animated_sprite.animation != animation:
		animated_sprite.animation = animation

	animate_footfalls()


func fire_projectile():
	if can_fire_projectile:
		attack_audio_player.play()
		
		var mouse_position = get_global_mouse_position()
		var projectile_instance = projectile.instantiate() as PlayerProjectile

		# assign origin to the projectile to use the stats of the origin character
		projectile_instance.origin = self

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
		await get_tree().create_timer(attack_rate, false).timeout
		can_fire_projectile = true


func _ready():
	super()
	
	Globals.player_instance = self

	$AnimatedSprite2D.animation = "idle"
	$AnimatedSprite2D.play()
	
	attack_damage_min = ATTACK_DMG_MIN
	attack_damage_max = ATTACK_DMG_MAX
	
	health_max = HEALTH_MAX
	move_speed = SPEED
	attack_rate = ATTACK_RATE
	attack_crit_chance_percentage = ATTACK_CRIT_CHANCE
	experience_needed_per_level_base = EXP_PER_LEVEL_BASE
	
	grant_experience(0)
	health_values_changed()


func _process(_delta):
	if Input.is_action_pressed("Shoot"):
		is_attacking = true
		
		fire_projectile()
	elif is_attacking:
		is_attacking = false
	
	animate_movement()
	
	# player is moving
	if velocity.length() != 0 and not footsteps_audio_player.playing:
		# apply pitch to speed up the playback when player is moving faster
		var playback_pitch = (abs(velocity.x) + abs(velocity.y)) / 110
		footsteps_audio_player.pitch_scale = playback_pitch
		footsteps_audio_player.play()


func _physics_process(_delta):
	# move
	process_directional_input()
	move_and_slide()
	# clamp position to be within world bounds
	position = position.clamp(Vector2.ZERO, MAP_BOUNDS)

