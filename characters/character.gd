class_name Character extends CharacterBody2D

@export var attack_damage: int = 0
@export var attack_damage_min: int = attack_damage
@export var attack_damage_max: int = attack_damage
@export var attack_crit_chance_percentage: int = 5
@export var attack_crit_chance_dmg: float = 1.5
@export var attack_rate: float = 1

@export var health_max: float = 100
@export var health_current: float = health_max
@export var health_percentage: int = 100

@export var is_alive: bool = true

@export var damage_reduction_flat: int = 0
@export var damage_reduction_percentage: int = 0

@export var move_speed: int = 100

@onready var rng: RandomNumberGenerator = RandomNumberGenerator.new()

func _on_hit(damage):
	var final_damage = (damage - damage_reduction_flat) - (damage * damage_reduction_percentage / 100)
	
	health_current -= final_damage
	
	health_percentage = round((health_current / health_max) * 100)
	
	if (health_current <= 0):
		on_death()


func _is_crit(crit_chance: int) -> bool:
	if crit_chance <= 0:
		return false
	else:
		var number = rng.randi_range(1, 100)
		
		return number >= 1 and number <= crit_chance


func _compute_hit_damage_by_character(attacker: Character) -> int:
	var damage := 0.0
	
	if attacker.attack_damage > 0:
		damage = attacker.attack_damage
	else:
		damage = randi_range(attacker.attack_damage_min, attacker.attack_damage_max)
		
	if attacker.attack_crit_chance_percentage > 0 && _is_crit(attacker.attack_crit_chance_percentage):
		damage += damage * attacker.attack_crit_chance_dmg
	
	return roundi(damage)


func _on_hit_by_character(attacker: Character):
	var damage = _compute_hit_damage_by_character(attacker)

	on_hit(damage)


func _on_death():
	pass


func _ready():
	rng.randomize()



func on_hit(damage: int):
	_on_hit(damage)


func on_hit_by_character(attacking_character: Character):
	_on_hit_by_character(attacking_character)


func on_death():
	is_alive = false

	_on_death()

