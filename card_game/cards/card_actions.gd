extends Area2D

var is_dragging: bool = false
var previous_mouse_position = Vector2()
var card
var full_card_info:String = ""
signal place_card_back_in_deck(card,location)
signal place_card_back_in_hand(card)
# Called when the node enters the scene tree for the first time.

func _ready() -> void:
	$timer.one_shot = true
	z_index = int(position.y)-2000
	pass


func set_card(card_object):
	card = card_object
	
	if "tl" in card_object:
		$card_base/top_left_label.text = card_object["tl"]
		full_card_info += card_object["tl"]
		
	if "tr" in card_object:
		$card_base/top_left_label.text += " " + card_object["tr"]
		full_card_info += '\n\n'+ card_object["tr"]
		
	if "middle" in card_object:
		full_card_info += '\n\n'+  card_object["middle"]
		
	if "bottom_left" in card_object:
		$card_base/bottom_label.text = card_object["bl"]
		full_card_info += '\n\n'+  card_object["bl"]
		
	if "bottom_right" in card_object:
		$card_base/bottom_label.text += " " + card_object["br"]
		full_card_info += '\n\n'+ card_object["br"]
		
	$MoreButton/MorePanel/MoreScrollContainer/MoreLabel.text = full_card_info
	
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
	
	$card_base/card_image.offset.x = 120/$card_base/card_image.scale.x
	$card_base/card_image.offset.y = ($card_base/card_image.texture.get_height())
	$card_base/card_image.centered = true

	
func _on_touch_input_event(_viewport, event, shape_idx):
	if not event.is_action_pressed("ui_touch"):
		return
	
	if $timer.is_stopped() == false:
		play_card()
		$timer.stop()
	else:
		$timer.start(.3)
	
	is_dragging = true
	previous_mouse_position = event.position

func play_card():
	if get_node("/root/board/cards") != get_parent():
			var new_parent = get_node("/root/board/cards")
			get_parent().remove_child(self)
			new_parent.add_child(self)
			position = Vector2(0-randf_range(0,100),0-randf_range(0,100))
			
func _input(event):
	if not is_dragging:
		return
		
	if event.is_action_released("ui_touch"):
		previous_mouse_position = Vector2()
		is_dragging = false
	
	if is_dragging and event is InputEventMouseMotion:
		position += (event.position - previous_mouse_position) # * get_tree().get_root().find_child("Camera2D").
		previous_mouse_position = event.position
	z_index = int(position.y)-2000


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


func _on_FlipButton_pressed() -> void:
	flip()


func _on_TapButton_pressed() -> void:
	if $card_base.get_rotation() == 0:
		$card_base.set_rotation(1.57)
	else:
		$card_base.set_rotation(0)


func _on_Return_pressed() -> void:
	$ReturnButton/place_menu.set_position(position+Vector2(100,125))
	$ReturnButton/place_menu.show()


func _on_MoreButton_pressed() -> void:
	$MoreButton/MorePanel.show()


func _on_CloseMoreButton_pressed() -> void:
	$MoreButton/MorePanel.hide()
