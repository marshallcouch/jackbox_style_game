extends Area2D


# Declare member variables here. Examples:
# var a: int = 2
# var b: String = "text"

var is_dragging: bool = false
var previous_mouse_position = Vector2()
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.
	
func _on_Draggable_input_event(viewport, event, shape_idx):
	if not event.is_action_pressed("ui_touch"):
		return
	print(shape_idx)
	
	#shape ID 0 means drag, they clicked the card
	if shape_idx == 0:
		print("draggable:" + event.to_string())
		get_tree().set_input_as_handled()
		previous_mouse_position = event.position
		is_dragging = true
		
	#shape ID 1 means tap
	elif shape_idx == 1:
		print("tap event: " + event.to_string())
		if $card_base.get_rotation() == 0:
			$card_base.set_rotation(1.57)
		else:
			$card_base.set_rotation(0)
			
	elif shape_idx == 2:
		print("flip event: " + event.to_string())
		if $card_base/card_back_sprite.visible:
			$card_base/card_back_sprite.visible = false
		else:
			$card_base/card_back_sprite.visible = true
			

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
