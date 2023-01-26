extends Area2D
# Declare member variables here. Examples:
# var a: int = 2
# var b: String = "text"

var is_dragging: bool = false
var previous_mouse_position = Vector2()
var card
signal place_card_back_in_deck(card,location)

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass


func set_card(card_object):
	card = card_object
	if "TopLeft" in card_object:
		$card_base/top_left_label.text = card_object["TopLeft"]
		
	if "TopRight" in card_object:
		$card_base/top_right_label.text = card_object["TopRight"]
		
	if "Middle" in card_object:
		$card_base/middle_label.text = card_object["Middle"]
		
	if "BottomLeft" in card_object:
		$card_base/bottom_left_label.text = card_object["BottomLeft"]
		
	if "BottomRight" in card_object:
		$card_base/bottom_right_label.text = card_object["BottomRight"]
		
	if "Type" in card_object:
		if card_object["Type"] in ["creature","defense","action","energy"]:
			$card_base/card_image.texture = load("res://assets/cards/" + card_object["Type"] +".png")
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
		
	z_index = position.y

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta: float) -> void:
#	pass


func _on_place_menu_index_pressed(index: int) -> void:
	if index == 0:
		emit_signal("place_card_back_in_deck",card,"top")
	elif index == 1:
		emit_signal("place_card_back_in_deck",card,"bottom")
	elif index == 2:
		return
		
	self.queue_free()
