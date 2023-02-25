extends Camera2D

var zoom_min = Vector2(.1,.1)
var zoom_max = Vector2(2,2)
var zoom_speed = Vector2(1, 1)
var previous_mouse_position = Vector2()
var is_dragging = false
var over_something = false
var scroll_zooming_enabled = true
const PANEL_WIDTH = 140
const PAN_SPEED = 10
signal show_hand

func _ready() -> void:
	get_tree().root.connect("size_changed", self, "_on_viewport_size_changed")
	_on_viewport_size_changed()
	if get_viewport().size.x < 1000:
		zoom = Vector2(.5,.5)
	
func _on_viewport_size_changed():
	# Do whatever you need to do when the window changes!
	$ActionPanel.transform = Transform2D(0,Vector2(
		get_viewport().size.x *.5 - (.5*PANEL_WIDTH)\
		,get_viewport().size.y - 180))
	zoom = Vector2(1080/get_viewport().size.y,1080/get_viewport().size.y)

func _process(delta):
	if $ActionPanel/LeftButton.pressed:
		offset_h -= 1 * delta * PAN_SPEED
	elif $ActionPanel/RightButton.pressed:
		offset_h += 1 * delta * PAN_SPEED
	elif $ActionPanel/DownButton.pressed:
		offset_v += 1 * delta * PAN_SPEED
	elif $ActionPanel/UpButton.pressed:
		offset_v -= 1 * delta * PAN_SPEED
	elif $ActionPanel/ZoomIn.pressed:
		if zoom > zoom_min:
			zoom -= zoom_speed * delta
	elif $ActionPanel/ZoomOut.pressed:
		if zoom < zoom_max:
			zoom += zoom_speed * delta 

func _on_recenter_button_pressed() -> void:
	offset_v = 0
	offset_h = 0
	zoom = Vector2(1,1)




func _on_HandButton_pressed() -> void:
	emit_signal("show_hand")
