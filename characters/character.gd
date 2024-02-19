class_name Character extends CharacterBody2D

@export var attack_damage: int = 0
@export var attack_damage_min: int = attack_damage
@export var attack_damage_max: int = attack_damage
@export var attack_crit_chance_percentage: int = 0
@export var attack_crit_chance_dmg: float = 1.5
@export var attack_rate: float = 1

@export var health_max: float = 100
@export var health_current: float = health_max
@export var health_percentage: int = 100

@export var is_alive: bool = true

@export var damage_reduction_flat: int = 0
@export var damage_reduction_percentage: int = 0

@export var move_speed: int = 100

@export var level_current: int = 1
@export var experience_current: int = 0
@export var experience_on_kill: int = 0
@export var experience_needed_per_level_base: int = 10000
@export var experience_to_next_level_total = experience_needed_per_level_base

@onready var rng: RandomNumberGenerator = RandomNumberGenerator.new()

# to be implemented by inheritors
# virtual
func on_hit_fct_callback(damage, is_crit):
	pass


func health_values_changed():
	health_current = health_max
	health_percentage = round((health_current / health_max) * 100)


func _ready():
	rng.randomize()

	grant_experience(experience_current)


func _on_hit(damage, is_crit):
	var final_damage = (damage - damage_reduction_flat) - (damage * damage_reduction_percentage / 100)
	
	on_hit_fct_callback(final_damage, is_crit)
	
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


func _compute_hit_damage_by_character(attacker: Character) -> HitResults:
	var damage := 0.0
	
	if attacker.attack_damage > 0:
		damage = attacker.attack_damage
	else:
		damage = randi_range(attacker.attack_damage_min, attacker.attack_damage_max)
	
	var is_hit_crit = _is_crit(attacker.attack_crit_chance_percentage)
	if attacker.attack_crit_chance_percentage > 0 && is_hit_crit:
		damage += damage * attacker.attack_crit_chance_dmg
	
	var rounded_damage = roundi(damage)
	var result = HitResults.new()
	result.damage = rounded_damage
	result.is_crit = is_hit_crit
	
	return result


func _on_hit_by_character(attacker: Character):
	if not is_alive:
		return

	var hit_results : HitResults = _compute_hit_damage_by_character(attacker)

	on_hit(hit_results.damage, hit_results.is_crit)
	
	if not is_alive:
		attacker.grant_experience(experience_on_kill)


func _on_death():
	pass


func on_hit(damage: int, is_crit: bool):
	_on_hit(damage, is_crit)


func on_hit_by_character(attacking_character: Character):
	_on_hit_by_character(attacking_character)


func on_death():
	is_alive = false

	_on_death()


func _get_experience_needed_for_levelup(current_level: int):
	return experience_needed_per_level_base * pow(current_level, 2)


func grant_experience(experience: int = 0):
	experience_current += experience
	experience_to_next_level_total = _get_experience_needed_for_levelup(level_current)

	var exp_to_next_level = experience_current - experience_to_next_level_total

	if exp_to_next_level >= 0:
		on_level_up()
		experience_current = 0
		# support multiple levelups to occur
		grant_experience(exp_to_next_level)


func _on_level_up():
	level_current += 1


func on_level_up():
	_on_level_up()


class HitResults:
	var damage: int
	var is_crit: bool
