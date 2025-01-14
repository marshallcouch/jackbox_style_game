extends Camera2D

var zoom_min = Vector2(.1,.1)
var zoom_max = Vector2(2,2)
var zoom_speed = Vector2(.5, .5)
var previous_mouse_position = Vector2()
var is_dragging = false
var over_something = false
var scroll_zooming_enabled = true
const PANEL_WIDTH = 140
const PAN_SPEED = 10
signal show_hand
signal menu
var camera_action: String = ""

func _ready() -> void:
	get_tree().root.connect("size_changed",Callable(self,"_on_viewport_size_changed"))
	_on_viewport_size_changed()
	
	
func _on_viewport_size_changed():
	if get_viewport().size.x < 1000:
		$ActionPanel.transform = Transform2D(0,Vector2(
			get_viewport().size.x *.5 - (.5*PANEL_WIDTH)\
			,get_viewport().size.y - 180))
		zoom = Vector2(1080/get_viewport().size.y,1080/get_viewport().size.y)
	else:
		$ActionPanel.transform = Transform2D(0,Vector2(20,20))

func _process(delta):
	if camera_action == "":
		return
	elif camera_action == "left":
		drag_horizontal_offset -= 1 * delta * PAN_SPEED
	elif camera_action == "right":
		drag_horizontal_offset += 1 * delta * PAN_SPEED
	elif camera_action == "down":
		drag_vertical_offset += 1 * delta * PAN_SPEED
	elif camera_action == "up":
		drag_vertical_offset -= 1 * delta * PAN_SPEED
	elif camera_action == "zoom_in":
		zoom += zoom_speed * delta
	elif camera_action == "zoom_out":
		zoom -= zoom_speed * delta 

func _on_recenter_button_pressed() -> void:
	drag_vertical_offset = 0
	drag_horizontal_offset = 0
	zoom = Vector2(1080/get_viewport().size.y,1080/get_viewport().size.y)


func _on_HandButton_pressed() -> void:
	emit_signal("show_hand")


func _on_ActionButtonMenu_pressed() -> void:
	emit_signal("menu") # Replace with function body.


func _on_move_button_pressed(action:String):
	self.camera_action = action


func _on_move_button_up():
	camera_action = "" # Replace with function body.


