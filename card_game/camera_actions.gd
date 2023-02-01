extends Camera2D

var zoom_min = Vector2(.1,.1)
var zoom_max = Vector2(2,2)
var zoom_speed = Vector2(.2, .2)
var previous_mouse_position = Vector2()
var is_dragging = false
var over_something = false
var scroll_zooming_enabled = true

func _ready() -> void:
	$action_panel/show_hide_hand_button.set_global_position(Vector2(10,get_viewport().size.y - 70))
	$player_hand.transform = Transform2D(0,Vector2(20,150))
		
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

	#start dragging
	elif event.is_action_pressed("ui_middle_mouse"):
		is_dragging = true
		previous_mouse_position = event.position


func _on_deck_change_camera_scroll(enabled) -> void:
	scroll_zooming_enabled = enabled

func _on_right_button_pressed() -> void:
	offset_h += 1

func _on_left_button_pressed() -> void:
	offset_h -= 1

func _on_down_button_pressed() -> void:
	offset_v += 1

func _on_up_button_pressed() -> void:
	offset_v -= 1

func _on_zoom_out_pressed() -> void:
	if zoom < zoom_max:
			zoom += zoom_speed

func _on_zoom_in_pressed() -> void:
	if zoom > zoom_min:
			zoom -= zoom_speed


func _on_show_hide_hand_button_pressed() -> void:
	if $player_hand.visible:
		$player_hand.hide()
		$action_panel/show_hide_hand_button.text = "Show"
	else:
		$player_hand.show()
		$action_panel/show_hide_hand_button.text = "Hide"


func _on_recenter_button_pressed() -> void:
	offset_v = 0
	offset_h = 0
	zoom = Vector2(1,1)
