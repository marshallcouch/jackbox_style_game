extends Node2D
class_name Board
var testing = true
var password:String = ""
var is_connected:bool = false
# The port we will listen to
# Our WebSocketServer instance

var client_id:int = -1


var web_server: WebServer = WebServer.new()

func _input(event):
	if event.is_action_released("ui_touch") and $camera/LargeCard.visible:
		$camera/LargeCard.hide()
	if event.is_action_released("ui_touch") and $camera/QRCode.visible:
		hide_qr_code()
	

func _ready() -> void:
	_load_preloaded_deck("pokemon_lugia_deck.tres")	
	web_server.start()
	web_server.client_connected.connect(hide_qr_code)

func display_large_card(tl:String, tr:String, mid:String, br:String, bl:String):
	$camera/LargeCard.set_card_parts(tl, tr, mid, br, bl)
	$camera/LargeCard.show()
	

func hide_qr_code():
	$camera/QRCode.hide()
	web_server.client_connected.disconnect(hide_qr_code)
	
func _on_deck_reveal_card(card_object) -> void:
	#print_debug("drawn card:" + card_object["top_left"])
	var drawn_card:Card = load("res://cards/card.tscn").instantiate()
	$cards.add_child(drawn_card)
	drawn_card.set_card(card_object)
	drawn_card.connect("place_card_back_in_deck",Callable($decks.get_child(0),"place_card_in_deck"))
	drawn_card.connect("place_card_back_in_hand",Callable(self,"_place_card_in_hand"))
	drawn_card.view_full_card.connect(display_large_card)
	var max_x = 100
	var max_y = 0
	for cards in $cards.get_children():
		if cards.position.x > max_x:
			max_x = cards.position.x
		if cards.position.y > max_y:
			max_y = cards.position.y
	drawn_card.position = Vector2(max_x + 20 ,max_y + 40)

	
func _on_deck_draw_card(card_object) -> void:
	#print_debug("drawn card:" + card_object["top_left"])
	var drawn_card:Card = load("res://cards/card.tscn").instantiate()
	drawn_card.set_card(card_object)
	_place_card_in_hand(drawn_card)
	drawn_card.connect("place_card_back_in_deck",Callable($decks.get_child(0),"place_card_in_deck"))
	drawn_card.connect("place_card_back_in_hand",Callable(self,"_place_card_in_hand"))
	drawn_card.view_full_card.connect(display_large_card)

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
		new_deck.connect("reveal_card",Callable(self,"_on_deck_reveal_card"))
		new_deck.position.y = get_viewport().size.y/2 - 230
		new_deck.position.x = get_viewport().size.x/2 - 125 + (220 * $decks.get_child_count())
		$decks.add_child(new_deck)


func _on_close_about_window_button_pressed() -> void:
	$camera/action_panel/action_menu_button/about_popup.hide() # Replace with function body.
	

func _process(_delta):
	web_server.process()


func _on_camera_remove_qr_code():
	$camera/QRCode.hide()
