extends Character

const SPEED = 100.0
const MAX_HEALTH = 100
const BODY_LIFETIME_SECONDS = 2

@onready var player := $"../Player"
@onready var nav_agent := $NavigationAgent2D
@onready var health_bar := $HealthBar as ProgressBar
@onready var animated_sprite := $AnimatedSprite2D as AnimatedSprite2D
@onready var collission_shape := $CollisionShape2D as CollisionShape2D


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
	super()

	animated_sprite.play("idle")
	
	attack_damage = 5
	health_max = MAX_HEALTH
	
	nav_agent.connect("velocity_computed", Callable(self, "move"))


func _process(delta):
	health_bar.value = health_percentage
	health_bar.visible = health_percentage < 100 and health_percentage > 0


func _physics_process(delta):
	if !is_alive:
		return

	# navigation is never finished - always follow the player
	#if nav_agent.is_navigation_finished():
		#return
	
	if player:
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


func _on_death():
	collission_shape.set_deferred('disabled', true)
	velocity = Vector2.ZERO
	nav_agent.velocity = Vector2.ZERO

	animated_sprite.play("death")

	await get_tree().create_timer(BODY_LIFETIME_SECONDS).timeout
	
	queue_free()
