extends Node2D
class_name Board
var testing = true
var password:String = ""
var is_connected:bool = false
# The port we will listen to
# Our WebSocketServer instance

var client_id:int = -1


var web_server: WebServer = WebServer.new()

		
func _ready() -> void:
	_load_preloaded_deck("pokemon_lugia_deck.tres")	
	web_server.start()
	web_server.client_connected.connect(hide_qr_code)

func hide_qr_code():
	$camera/QRCode.hide()
	web_server.client_connected.disconnect(hide_qr_code)
	
func _on_deck_draw_card(card_object) -> void:
	#print_debug("drawn card:" + card_object["top_left"])
	var drawn_card = load("res://cards/card.tscn").instantiate()
	drawn_card.set_card(card_object)
	_place_card_in_hand(drawn_card)
	drawn_card.connect("place_card_back_in_deck",Callable($decks.get_child(0),"place_card_in_deck"))
	drawn_card.connect("place_card_back_in_hand",Callable(self,"_place_card_in_hand"))

func _place_card_in_hand(card_scene):
	var max_x = 0
	var max_y = 0
	for cards in $camera/player_hand.get_children():
		if cards.position.x > max_x:
			max_x = cards.position.x
		if cards.position.y > max_y:
			max_y = cards.position.y
	card_scene.position = Vector2(max_x + 20 ,max_y + 40)
#	if(card_scene.is_face_down()):
#		card_scene.flip()
	if card_scene.get_parent() == $cards:
		card_scene.get_parent().remove_child(card_scene)
	$camera/player_hand.add_child(card_scene)

func _load_preloaded_deck(filename: String) -> void:
	print_debug("loading...")
	var deck_file:JSON = load("res://assets/preloaded_decks/" + filename)
	var json_text = deck_file.data
	_on_action_menu_json_pasted(json_text)


func _load_deck(filename: String) -> void:
	print_debug("loading...")
	var deck_file = FileAccess.open("res://assets/preloaded_decks/" + filename,FileAccess.READ)

	_on_action_menu_json_pasted(deck_file.get_as_text())
	deck_file.close()

func _on_action_menu_json_pasted(json_text) -> void:
	var json_result =json_text
	
	var _game_name 
	if "game" in json_result:
		_game_name = String(json_result["game"])
	#print_debug(deck_result)
	var new_deck
	for deck in json_result["decks"]:
		new_deck = load("res://cards/card_deck.tscn").instantiate()
		new_deck.load_deck(String(json_result["game"]), deck["deck_name"], deck["deck"])
		new_deck.connect("draw_card",Callable(self,"_on_deck_draw_card"))
		
		new_deck.position.y = get_viewport().size.y/2 - 190 
		new_deck.position.x = get_viewport().size.x/2 - 125 + (220 * $decks.get_child_count())
		$decks.add_child(new_deck)


func _on_close_about_window_button_pressed() -> void:
	$camera/action_panel/action_menu_button/about_popup.hide() # Replace with function body.
	

func _process(_delta):
	web_server.process()
	
