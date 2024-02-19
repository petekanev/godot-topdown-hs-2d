extends CanvasLayer

@onready var health_bar = $HealthReferenceRect/ProgressBar
@onready var attack_range_label = $StatsReferenceRect/TextureRect/AttackRefRect/AttackRangeLabel as Label
@onready var level_label = $StatsReferenceRect/TextureRect/LevelRefRect/LevelLabel as Label
@onready var exp_label = $StatsReferenceRect/TextureRect/ExpRefRect/ExpLabel as Label

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	health_bar.value = Globals.player_instance.health_percentage
	
	var attack_range = "%s - %s" % [Globals.player_instance.attack_damage_min, Globals.player_instance.attack_damage_max] 
	if not attack_range_label.text == attack_range:
		attack_range_label.text = attack_range
	
	var level_current = str(Globals.player_instance.level_current)
	if not level_label.text == level_current:
		level_label.text = level_current
		
	var exp_to_next_level = Globals.player_instance.experience_to_next_level_total
	var exp_range = "%s / %s" % [Globals.player_instance.experience_current, exp_to_next_level]
	exp_label.text = exp_range
	
