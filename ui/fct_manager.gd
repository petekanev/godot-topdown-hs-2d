class_name FCTManager extends Node
## Floating Combat Text Manager 
##
## The class will display floating numbers relative
## to the parent node's position, within the parent's parent node

var FloatingCombatText = preload("res://ui/floating_combat_text.tscn")

@export var fct_travel = Vector2(0, -80)
@export var fct_duration = 1
@export var fct_spread = PI/2

var parent : Node
var parentTopLevel : Node
var configured : bool = false


func _ready():
	# the parent 2 levels up should be the body's container/root
	parent = get_parent()

	if parent:
		parentTopLevel = parent.get_parent()
		
		if parentTopLevel:
			configured = true
			
	if not configured:
		var first_level_parent = parent
		push_warning((
			"FCTManager not configured for %s because the parent node (2 levels up) is missing or is invalid" % first_level_parent
		))


func show_fct(value, is_crit = false):
	if not configured:
		return

	var fct: FCT = FloatingCombatText.instantiate()
	parentTopLevel.add_child(fct)

	fct.show_value(parent.position, value, fct_travel, fct_duration, fct_spread, is_crit)
