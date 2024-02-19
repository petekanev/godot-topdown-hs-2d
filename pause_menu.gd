extends Node2D

# Called when the node enters the scene tree for the first time.
func _ready():
	hide()


func toggle_pause():
	var viewport = get_viewport()
	
	# position the overlay in the middle of the player screen
	if viewport:
		var active_camera = viewport.get_camera_2d()
		if active_camera:
			var screen_center = active_camera.get_screen_center_position()
			position = screen_center
	
	var scene_tree = get_tree()
	var next_pause_state = not scene_tree.paused
	
	visible = next_pause_state
	scene_tree.paused = next_pause_state


func _unhandled_key_input(event):
	if event.is_action_pressed("Pause"):
		toggle_pause()


func _on_continue_btn_pressed():
	toggle_pause()


func _on_main_menu_btn_pressed():
	pass # Replace with function body.
