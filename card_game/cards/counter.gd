extends Area2D


# Declare member variables here. Examples:
# var a: int = 2
# var b: String = "text"

var is_dragging: bool = false
var previous_mouse_position = Vector2()
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$timer.one_shot = true
	
	pass # Replace with function body.


func _on_touch_input_event(_viewport, event, shape_idx):
	if not event.is_action_pressed("ui_touch"):
		return
	
	#shape ID 0 means drag, they clicked the card
	if shape_idx == 0:
		print_debug("draggable:" + event.to_string())
		get_tree().set_input_as_handled()
		previous_mouse_position = event.position
		is_dragging = true
		
		if $counter_edit.visible:
			$counter_label.text = $counter_edit.text
			$counter_edit.visible = false
			$delete_button.hide()
		
		if $timer.is_stopped() == false:
			$counter_edit.visible = true
			$delete_button.show()
			print_debug("double click!")
			$timer.stop()
		else:
			$timer.start(.3)
			
		
		


func _input(event):
	if not is_dragging:
		return
		
	if event.is_action_released("ui_touch"):
		previous_mouse_position = Vector2()
		is_dragging = false
	
	if is_dragging and event is InputEventMouseMotion:
		position += (event.position - previous_mouse_position) # * get_tree().get_root().find_node("Camera2D").
		previous_mouse_position = event.position

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta: float) -> void:
#	pass
	


func _on_delete_button_pressed() -> void:
	self.queue_free()
	pass # Replace with function body.
