extends Camera2D

var zoom_min = Vector2(.1,.1)
var zoom_max = Vector2(2,2)
var zoom_speed = Vector2(.05, .05)
var previous_mouse_position = Vector2()
var is_dragging = false
var over_something = false
var scroll_zooming_enabled = true

func _input(event):
	#handle dragging
	if is_dragging and event is InputEventMouseMotion:
		offset -= (event.position - previous_mouse_position) * zoom
		previous_mouse_position = event.position
		
	if not event is InputEventMouseButton:
		return
	if not event.is_pressed():
		
		#End dragging
		if event.is_action_released("ui_middle_mouse"):
			previous_mouse_position = event.position
			is_dragging = false
		return
	
	if event.is_action_pressed("ui_scroll_down"):
		if not scroll_zooming_enabled:
			return
		if zoom < zoom_max:
			zoom += zoom_speed
	elif event.is_action_pressed("ui_scroll_up"):
		if not scroll_zooming_enabled:
			return
		if zoom > zoom_min:
			zoom -= zoom_speed
			
	#start dragging
	elif event.is_action_pressed("ui_middle_mouse"):
		is_dragging = true
		previous_mouse_position = event.position
		
		
		


func _on_deck_change_camera_scroll(enabled) -> void:
	scroll_zooming_enabled = enabled
