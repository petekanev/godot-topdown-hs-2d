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

@onready var rng: RandomNumberGenerator = RandomNumberGenerator.new()

var FloatingCombatText = preload("res://ui/floating_combat_text.tscn")

@export var fct_travel = Vector2(0, -80)
@export var fct_duration = 1
@export var fct_spread = PI/2


func health_values_changed():
	health_current = health_max
	health_percentage = round((health_current / health_max) * 100)


func _ready():
	rng.randomize()


func show_value(value, crit = false):
	var fct: FCT = FloatingCombatText.instantiate()
	get_parent().add_child(fct)
	fct.show_value(position, value, fct_travel, fct_duration, fct_spread, crit)


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


func _compute_hit_damage_by_character(attacker: Character) -> HitResultsStruct:
	var damage := 0.0
	
	if attacker.attack_damage > 0:
		damage = attacker.attack_damage
	else:
		damage = randi_range(attacker.attack_damage_min, attacker.attack_damage_max)
	
	var is_hit_crit = _is_crit(attacker.attack_crit_chance_percentage)
	if attacker.attack_crit_chance_percentage > 0 && is_hit_crit:
		damage += damage * attacker.attack_crit_chance_dmg
	
	var rounded_damage = roundi(damage)
	var result = HitResultsStruct.new()
	result.damage = rounded_damage
	result.is_crit = is_hit_crit
	
	return result


func _on_hit_by_character(attacker: Character):
	var hit_results : HitResultsStruct = _compute_hit_damage_by_character(attacker)

	show_value(hit_results.damage, hit_results.is_crit)

	on_hit(hit_results.damage)


func _on_death():
	pass


func on_hit(damage: int):
	_on_hit(damage)


func on_hit_by_character(attacking_character: Character):
	_on_hit_by_character(attacking_character)


func on_death():
	is_alive = false

	_on_death()

