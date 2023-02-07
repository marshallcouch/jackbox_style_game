extends Node2D
class_name Board
var testing = true
var password:String = ""
var peer: NetworkedMultiplayerENet


func _ready() -> void:
	if testing:
		var deck_file = File.new()
		deck_file.open("C:\\Users\\marsh\\Documents\\Godot\\jackbox_style_game\\card_game\\assets\\cards\\MTGdeck.json",File.READ)
		_on_action_menu_json_pasted(deck_file.get_as_text())
		deck_file.close()
	setup_about()
	peer = NetworkedMultiplayerENet.new()
	peer.create_server(1337,2)
	get_tree().network_peer = peer

func draw_card() -> Dictionary:
	setup_about()
	return {"key1":"test"}
	
func setup_about():
	password = String(ceil(rand_range(1000,9999)))
	var ip = ""
	for address in IP.get_local_addresses():
		if (address.split('.').size() == 4):
			ip += "\n" + address
	$camera/action_panel/action_menu_button/about_popup/about_label.text = "ip: " + ip
	$camera/action_panel/action_menu_button/about_popup/about_label.text += "\n\npassowrd: " + password
	$camera/action_panel/action_menu_button/about_popup.show()

func _on_deck_draw_card(card_object) -> void:
	print_debug("drawn card:" + card_object["top_left"])
	var drawn_card = load("res://cards/card.tscn").instance()
	drawn_card.set_card(card_object)
	_place_card_in_hand(drawn_card)
	drawn_card.connect("place_card_back_in_deck",$decks.get_child(0),"_place_card_in_deck")
	drawn_card.connect("place_card_back_in_hand",self,"_place_card_in_hand")

func _place_card_in_hand(card_scene):
	var max_x = 0
	var max_y = 0
	for cards in $camera/player_hand.get_children():
		if cards.position.x > max_x:
			max_x = cards.position.x
		if cards.position.y > max_y:
			max_y = cards.position.y
	card_scene.position = Vector2(max_x + 20 + rand_range(0,10),max_y + 40 + rand_range(0,30))
	if(card_scene.is_face_down()):
		card_scene.flip()
	if card_scene.get_parent() == $cards:
		card_scene.get_parent().remove_child(card_scene)
	$camera/player_hand.add_child(card_scene)


func _on_action_menu_json_pasted(json_text) -> void:
	var json_result = JSON.parse(json_text).result
	var _game_name = String(json_result["game"])
	#print_debug(deck_result)
	var new_deck
	for deck in json_result["decks"]:
		new_deck = load("res://cards/card_deck.tscn").instance()
		new_deck.load_deck(String(json_result["game"]), deck["deck_name"], deck["deck"])
		new_deck.connect("draw_card",self, "_on_deck_draw_card")
		
		new_deck.position.y = get_viewport().size.y/2 - 380 
		new_deck.position.x = get_viewport().size.x/2 - 250 + (300 * $decks.get_child_count())
		$decks.add_child(new_deck)


func _on_close_about_window_button_pressed() -> void:
	$camera/action_panel/action_menu_button/about_popup.hide() # Replace with function body.
