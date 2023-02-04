extends Area2D

var is_dragging: bool = false
var previous_mouse_position = Vector2()
var card
var is_selected: bool = false
signal place_card_back_in_deck(card,location)
signal place_card_back_in_hand(card)
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$timer.one_shot = true
	z_index = position.y-2000
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
	print_debug(shape_idx)
	is_selected = true
	
	if $timer.is_stopped() == false and is_selected:
		print_debug("double click!")
		if get_node("/root/board/cards") != get_parent():
			var new_parent = get_node("/root/board/cards")
			get_parent().remove_child(self)
			new_parent.add_child(self)
			position = Vector2(0-rand_range(0,250),0-rand_range(0,350))
		$timer.stop()
	else:
		for other_cards in get_parent().get_children():
			if other_cards != self:
				if other_cards.z_index > z_index and overlaps_area(other_cards) and other_cards.is_selected:
					is_selected = false
					return
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
		flip()
	
	elif shape_idx == 3:
		$place_in_deck_box/place_menu.set_position(position+Vector2(200,250))
		$place_in_deck_box/place_menu.show()

func _input(event):
	if not is_dragging:
		return
		
	if event.is_action_released("ui_touch"):
		previous_mouse_position = Vector2()
		is_dragging = false
	
	for other_card in get_parent().get_children():
		if other_card != self:
			if other_card.z_index > z_index and overlaps_area(other_card) and other_card.is_dragging:
				is_dragging = false
				return
	
	if is_dragging and event is InputEventMouseMotion:
		position += (event.position - previous_mouse_position) # * get_tree().get_root().find_node("Camera2D").
		previous_mouse_position = event.position
		1
	z_index = position.y-2000

func is_face_down() -> bool:
	return $card_base/card_back_sprite.visible

func flip():
	if $card_base/card_back_sprite.visible:
		$card_base/card_back_sprite.visible = false
	else:
		$card_base/card_back_sprite.visible = true

func _on_place_menu_index_pressed(index: int) -> void:
	if index == 0:
		emit_signal("place_card_back_in_deck",card,"top")
	elif index == 1:
		emit_signal("place_card_back_in_deck",card,"bottom")
	elif index == 2:
		emit_signal("place_card_back_in_hand",self)
		return
	elif index == 3:
		return
		
	self.queue_free()
