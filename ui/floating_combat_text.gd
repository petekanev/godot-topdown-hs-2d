class_name FCT extends Node2D

@onready var fct_label: Label = $FCT
var tween: Tween


# Called when the node enters the scene tree for the first time.
func _ready():
	tween = create_tween()
	tween.bind_node(fct_label)
	tween.stop()

	# will run all transformations simultaneously
	tween.set_parallel(true)
	
	fct_label.z_index = 200


func show_value(position: Vector2, value: int, travel: Vector2, duration: float, spread: float, crit: bool = false):	
	fct_label.position = position + Vector2(-10, -50)

	fct_label.text = str(value)
	var movement = travel.rotated(randf_range(-spread/2, spread/2))
	fct_label.pivot_offset = fct_label.size / 2
	
	# will float out the text to position+movement in duration
	( tween
		.tween_property(fct_label, "position", fct_label.position + movement, duration)
		.set_trans(Tween.TRANS_LINEAR)
		.set_ease(Tween.EASE_IN_OUT)
	)
	
	# will fade-out the text to 0 in duration
	( tween
		.tween_property(fct_label, "modulate:a", 0.0, duration)
		.set_trans(Tween.TRANS_LINEAR)
		.set_ease(Tween.EASE_IN_OUT)
	)
	
	if crit:
		modulate = Color(1, 0, 0)
		( tween
			.tween_property(fct_label, "scale", fct_label.scale * 2, 0.4)
			.set_trans(Tween.TRANS_BACK)
			.set_ease(Tween.EASE_IN)
		)

	prints(Time.get_time_string_from_system())
	tween.play()
	
	await tween.finished
	prints(Time.get_time_string_from_system())
	prints("tween finished")
	queue_free()
