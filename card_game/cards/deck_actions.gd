extends Area2D

var is_dragging: bool = false
var previous_mouse_position = Vector2()
var deck_array:Array = []

signal draw_card(card_object)
signal reveal_card(card_object)
signal view_full_card(tl,tr,mid, bl, br)
var game_name:String = ""
var deck_name:String = ""
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass
func on_release():
	z_index = int(position.y)-2000
func load_deck(_game_name, _deck_name, deck_json) -> void:
	for card in deck_json:
		for _j in range(0,card["count"]):
			deck_array.push_front(card)
	$card_count_label.text = str(deck_array.size())
	self.game_name = _game_name
	self.deck_name = _deck_name
	$deck_name_label.text = deck_name
	deck_array.shuffle()

func on_click():
	pass
#func _on_touch_input_event(_viewport, event, shape_idx):
	#if not event.is_action_pressed("ui_touch"):
		#return
	#
	##shape ID 0 means drag, they clicked the deck
	#if shape_idx == 0:
		#get_viewport().set_input_as_handled()
		#previous_mouse_position = event.position
		#is_dragging = true
	#



func _search_deck() -> void:
	var vscroll = $deck_search_box/deck_search.get_v_scroll_bar()
	vscroll.size.x = 30
	vscroll.position.x =322
	if $deck_search_box.visible == false:
		for card in deck_array:
			var card_in_deck = load("res://cards/card_in_deck.tscn").instantiate()
			card_in_deck._set_label(card["tl"])
			card_in_deck.set_card(card)
			$deck_search_box/deck_search/deck_list.add_child(card_in_deck)
			card_in_deck.connect("draw_card_from_deck", Callable(self, "_draw_card_from_deck"))
			card_in_deck.connect("view_full_card", Callable(self, "_view_full_card"))
		$deck_search_box.show()
	else:
		_hide_deck_search()
func _view_full_card(tl,tr,mid, bl, br):
	view_full_card.emit(tl,tr,mid, bl, br)
	
func _hide_deck_search():
	for n in $deck_search_box/deck_search/deck_list.get_children():
			$deck_search_box/deck_search/deck_list.remove_child(n)
			n.queue_free()
	$deck_search_box.hide()


func _shuffle_deck() -> void:
	if deck_array.size() >1:
		deck_array.shuffle()


func _draw_card() -> void:
	if deck_array.size() >0:
		emit_signal("draw_card",deck_array.pop_front())
		_set_deck_cards_visible()

func _reveal_card() -> void:
	if deck_array.size() >0:
		emit_signal("reveal_card",deck_array.pop_front())
		_set_deck_cards_visible()


func _draw_card_from_deck(card_to_draw):
	for card in deck_array:
		if card["tl"] == card_to_draw:
			deck_array.pop_at(deck_array.find(card))
			emit_signal("draw_card",card)
			break
	_set_deck_cards_visible()
	_hide_deck_search()


func _set_deck_cards_visible():
	$card_count_label.text = str(deck_array.size())
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
		position += (event.position - previous_mouse_position) # * get_tree().get_root().find_child("Camera2D").
		previous_mouse_position = event.position


func place_card_in_deck(card, location):
	if location == "top":
		deck_array.push_front(card)
	elif location == "bottom":
		deck_array.push_back(card)
	_set_deck_cards_visible()


func _on_ShuffleButton_pressed() -> void:
	_shuffle_deck()

func _on_DrawButton_pressed() -> void:
	_draw_card()

func _on_SearchButton_pressed() -> void:
	_search_deck()


func _on_reveal_button_pressed():
	_reveal_card()
