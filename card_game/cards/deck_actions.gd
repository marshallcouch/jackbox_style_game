extends Area2D


# Declare member variables here. Examples:
# var a: int = 2
# var b: String = "text"

var is_dragging: bool = false
var previous_mouse_position = Vector2()
var deck_array:Array = []
var deck_result:Array
signal draw_card(card_object)

# Called when the node enters the scene tree for the first time.
func _init() -> void:
	var deck_file = File.new()
	deck_file.open("res://assets/cards/MTGdeck.json",File.READ)
	print(deck_file.get_as_text())
	deck_result = JSON.parse(deck_file.get_as_text()).result
	deck_file.close()
	print(deck_result)
	for card in deck_result:
		for _i in range(0,card["count"]):
			deck_array.push_front(card)
			#print(card["TopLeft"])
			
	
	
	
func _on_touch_input_event(viewport, event, shape_idx):
	if not event.is_action_pressed("ui_touch"):
		return
	print_debug(shape_idx)
	
	#shape ID 0 means drag, they clicked the deck
	if shape_idx == 0:
		print_debug("draggable:" + event.to_string())
		get_tree().set_input_as_handled()
		previous_mouse_position = event.position
		is_dragging = true
	
	#shuffle
	if shape_idx == 1:
		_shuffle_deck(event)
		
	#Draw
	if shape_idx == 2:
		_draw_card(event)
	
	if shape_idx == 3:
		_search_deck(event)


func _search_deck(event) -> void:
	pass

func _shuffle_deck(event) -> void:
	print_debug("shuffle:" + event.to_string())
	deck_array.shuffle()
	print_debug(deck_array[1]["TopLeft"])
	
func _draw_card(event) -> void:
	emit_signal("draw_card",deck_array.pop_front())
	print_debug("draw:" + event.to_string())
	$card_count_label.text = String(deck_array.size())
	if deck_array.size() == 2:
		$card_back_sprite3.visible = false
	elif deck_array.size() == 1:
		$card_back_sprite3.visible = false
		$card_back_sprite2.visible = false
	elif  deck_array.size() == 0:
		$card_back_sprite3.visible = false
		$card_back_sprite2.visible = false
		$card_back_sprite.visible = false
	else:
		if not $card_back_sprite3.visible or not $card_back_sprite3.visible or not $card_back_sprite3.visible:
			$card_back_sprite3.visible = true
			$card_back_sprite2.visible = true
			$card_back_sprite.visible = true
		

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
