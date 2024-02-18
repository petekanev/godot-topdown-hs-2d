extends CanvasLayer

@onready var health_bar = $HealthReferenceRect/ProgressBar
@onready var attack_range_label = $StatsReferenceRect/TextureRect/AttackRangeLabel as Label

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	health_bar.value = Globals.player_instance.health_percentage
	
	var attack_range = "%s - %s" % [Globals.player_instance.attack_damage_min, Globals.player_instance.attack_damage_max] 
	if not attack_range_label.text == attack_range:
		attack_range_label.text = attack_range
