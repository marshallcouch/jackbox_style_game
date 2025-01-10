extends Area2D
class_name Card

var is_dragging: bool = false
var previous_mouse_position = Vector2()
var card
var tl:String = ""
var tr:String = ""
var mid:String = ""
var br:String = ""
var bl:String = ""
signal place_card_back_in_deck(card,location)
signal place_card_back_in_hand(card)
signal view_full_card(tl,tr,mid, bl, br)
func on_click():
	pass

func on_release():
	z_index = int(position.y)-2000
	
func _ready() -> void:
	$timer.one_shot = true
	z_index = int(position.y)-2000
	pass


func set_card(card_object):
	card = card_object
	
	if "tl" in card_object:
		tl = card_object["tl"]
		$card_base/top_left_label.text = tl
		
		
	if "tr" in card_object:
		tr = card_object["tr"]
		$card_base/top_left_label.text += "\n" + tr
		
	if "middle" in card_object:
		mid = card_object["middle"]
		
	if "bl" in card_object:
		bl =  card_object["bl"]
		$card_base/bottom_label.text = bl
		
	if "br" in card_object:
		br = card_object["br"]
		$card_base/bottom_label.text += "\n" + br
		
	
func _on_touch_input_event(_viewport, event, shape_idx):
	if not event.is_action_pressed("ui_touch"):
		return
	
	if $timer.is_stopped() == false:
		play_card()
		$timer.stop()
	else:
		$timer.start(.3)
	
	#is_dragging = true
	#previous_mouse_position = event.position

func play_card():
	if get_node("/root/board/cards") != get_parent():
			var new_parent = get_node("/root/board/cards")
			get_parent().remove_child(self)
			new_parent.add_child(self)
			position = Vector2(0-randf_range(0,100),0-randf_range(0,100))
func play_card_face_down():
	play_card()
	$card_base/card_back_sprite.show()
	
#func _input(event):
	#if not is_dragging:
		#return
		#
	#if event.is_action_released("ui_touch"):
		#previous_mouse_position = Vector2()
		#is_dragging = false
	#
	#if is_dragging and event is InputEventMouseMotion:
		#position += (event.position - previous_mouse_position) # * get_tree().get_root().find_child("Camera2D").
		#previous_mouse_position = event.position
	#z_index = int(position.y)-2000


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
	$ReturnButton/place_menu.position = position+Vector2(140,370)
	if get_parent().name == "cards":
		$ReturnButton/place_menu.position -= Vector2i(get_viewport().get_camera_2d().offset*get_viewport().get_camera_2d().zoom.x) - Vector2i(580,220)
	$ReturnButton/place_menu.show()


func _on_MoreButton_pressed() -> void:
	view_full_card.emit(tl,tr,mid,bl,br)


func _on_CloseMoreButton_pressed() -> void:
	$MoreButton/MorePanel.hide()
