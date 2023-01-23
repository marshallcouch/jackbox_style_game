extends Area2D


# Declare member variables here. Examples:
# var a: int = 2
# var b: String = "text"

var is_dragging: bool = false
var previous_mouse_position = Vector2()
var deck_array:Array
var deck_result:Array
# Called when the node enters the scene tree for the first time.
func _init() -> void:
	var deck_file = File.new()
	deck_file.open("res://assets/cards/MTGdeck.json",File.READ)
	print(deck_file.get_as_text())
	deck_result = JSON.parse(deck_file.get_as_text()).result
	deck_file.close()
	print(deck_result)
	for card in deck_result:
		for i in range(0,card["count"]):
			deck_array.push_front(card)
			print(card["TopLeft"])
			
	
	
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
