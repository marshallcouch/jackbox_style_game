extends Area2D

var is_dragging: bool = false
var previous_mouse_position = Vector2()
var card
signal place_card_back_in_deck(card,location)

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$timer.one_shot = true
	pass


func set_card(card_object):
	card = card_object
	if "top_left" in card_object:
		$card_base/top_left_label.text = card_object["top_left"]
		
	if "top_right" in card_object:
		$card_base/top_right_label.text = card_object["top_right"]
		
	if "middle" in card_object:
		$card_base/middle_label.text = card_object["middle"]
		
	if "bottom_left" in card_object:
		$card_base/bottom_left_label.text = card_object["bottom_left"]
		
	if "bottom_right" in card_object:
		$card_base/bottom_right_label.text = card_object["bottom_right"]
		
	if "type" in card_object:
		if card_object["type"] in ["creature","defense","action","energy"]:
			$card_base/card_image.texture = load("res://assets/cards/" + card_object["type"] +".png")
		else:
			$card_base/card_image.texture = load("res://assets/cards/unknown.png")
	else:
		$card_base/card_image.texture = load("res://assets/cards/unknown.png")
		
	#scale card image and place it properly
	if $card_base/card_image.texture.get_height() > $card_base/card_image.texture.get_width():
		$card_base/card_image.scale *= 100.0/$card_base/card_image.texture.get_height()
	else: 
		$card_base/card_image.scale *= 100.0/$card_base/card_image.texture.get_width()
	
	$card_base/card_image.offset.x = 125/$card_base/card_image.scale.x
	$card_base/card_image.offset.y = ($card_base/card_image.texture.get_height())
	$card_base/card_image.centered = true

	
func _on_touch_input_event(viewport, event, shape_idx):
	if not event.is_action_pressed("ui_touch"):
		return
	print(shape_idx)
	
	if $timer.is_stopped() == false:
		print_debug("double click!")
		var new_parent = get_node("/root/board/cards")
		get_parent().remove_child(self)
		new_parent.add_child(self)
		$timer.stop()
	else:
		$timer.start(.3)
	#shape ID 0 means drag, they clicked the card
	if shape_idx == 0:
		get_tree().set_input_as_handled()
		previous_mouse_position = event.position
		is_dragging = true
		
	#shape ID 1 means tap
	elif shape_idx == 1:
		if $card_base.get_rotation() == 0:
			$card_base.set_rotation(1.57)
		else:
			$card_base.set_rotation(0)
			
	elif shape_idx == 2:
		if $card_base/card_back_sprite.visible:
			$card_base/card_back_sprite.visible = false
		else:
			$card_base/card_back_sprite.visible = true
	
	elif shape_idx == 3:
		$place_in_deck_box/place_menu.set_position(self.position+Vector2(200,300))
		$place_in_deck_box.z_index = 400
		$place_in_deck_box/place_menu.show()
			

func _input(event):
	if not is_dragging:
		return
		
	if event.is_action_released("ui_touch"):
		previous_mouse_position = Vector2()
		is_dragging = false
	
	if is_dragging and event is InputEventMouseMotion:
		position += (event.position - previous_mouse_position) # * get_tree().get_root().find_node("Camera2D").
		previous_mouse_position = event.position
		1
	z_index = position.y


func _on_place_menu_index_pressed(index: int) -> void:
	if index == 0:
		emit_signal("place_card_back_in_deck",card,"top")
	elif index == 1:
		emit_signal("place_card_back_in_deck",card,"bottom")
	elif index == 2:
		return
		
	self.queue_free()
