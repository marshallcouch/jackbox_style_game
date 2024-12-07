extends Node2D
class_name Board
var testing = true
var password:String = ""
var is_connected:bool = false
# The port we will listen to
const PORT = 8181
# Our WebSocketServer instance
var _server = WebSocketServer.new()
var client_id:int = -1

func _ready() -> void:
	_load_preloaded_deck("pokemon_lugia_deck.tres")
	#setup_about()
	setup_server()
	#get_image_from_google("llanowar elves")
	
	
	
func setup_about():
	password = String(ceil(rand_range(1000,9999)))
	var ip = ""
	for address in IP.get_local_addresses():
		if (address.split('.').size() == 4):
			ip += "\n" + address
	$camera/action_panel/action_menu_button/about_popup/about_label.text = "ip: " + ip
	$camera/action_panel/action_menu_button/about_popup/about_label.text += "\n\npassword: " + password
	$camera/action_panel/action_menu_button/about_popup.show()

func _on_deck_draw_card(card_object) -> void:
	#print_debug("drawn card:" + card_object["top_left"])
	var drawn_card = load("res://cards/card.tscn").instance()
	drawn_card.set_card(card_object)
	_place_card_in_hand(drawn_card)
	drawn_card.connect("place_card_back_in_deck",$decks.get_child(0),"place_card_in_deck")
	drawn_card.connect("place_card_back_in_hand",self,"_place_card_in_hand")

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
	if is_connected:
		_server.get_peer(client_id).put_packet("card~".to_utf8() + String(JSON.print(card_scene.card)).to_utf8())

func _load_preloaded_deck(filename: String) -> void:
	print_debug("loading...")
	var deck_file = File.new()
	deck_file.open("res://assets/preloaded_decks/" + filename,File.READ)
	_on_action_menu_json_pasted(deck_file.get_as_text().replace("[gd_resource type=\"Resource\" format=2]","").replace("[resource]",""))
	deck_file.close()

func _load_deck(filename: String) -> void:
	print_debug("loading...")
	var deck_file = File.new()
	deck_file.open(filename,File.READ)
	_on_action_menu_json_pasted(deck_file.get_as_text().replace("[gd_resource type=\"Resource\" format=2]","").replace("[resource]",""))
	deck_file.close()

func _on_action_menu_json_pasted(json_text) -> void:
	var json_result = JSON.parse(json_text).result
	
	var _game_name 
	if "game" in json_result:
		_game_name = String(json_result["game"])
	#print_debug(deck_result)
	var new_deck
	for deck in json_result["decks"]:
		new_deck = load("res://cards/card_deck.tscn").instance()
		new_deck.load_deck(String(json_result["game"]), deck["deck_name"], deck["deck"])
		new_deck.connect("draw_card",self, "_on_deck_draw_card")
		
		new_deck.position.y = get_viewport().size.y/2 - 190 
		new_deck.position.x = get_viewport().size.x/2 - 125 + (220 * $decks.get_child_count())
		$decks.add_child(new_deck)


func _on_close_about_window_button_pressed() -> void:
	$camera/action_panel/action_menu_button/about_popup.hide() # Replace with function body.




func setup_server():
	# Connect base signals to get notified of new client connections,
	# disconnections, and disconnect requests.
	_server.connect("client_connected", self, "_connected")
	_server.connect("client_disconnected", self, "_disconnected")
	_server.connect("client_close_request", self, "_close_request")
	# This signal is emitted when not using the Multiplayer API every time a
	# full packet is received.
	# Alternatively, you could check get_peer(PEER_ID).get_available_packets()
	# in a loop for each connected peer.
	_server.connect("data_received", self, "_on_data")
	# Start listening on the given port.
	var err = _server.listen(PORT,["my-protocol"],false)
	if err != OK:
		set_process(false)
		print("error with server")
	

func _connected(id, proto):
	# This is called when a new peer connects, "id" will be the assigned peer id,
	# "proto" will be the selected WebSocket sub-protocol (which is optional)
	print_debug("Client %d connected with protocol: %s" % [id, proto])
	is_connected = true
	client_id = id
	for cards in $camera/player_hand.get_children():
		_server.get_peer(client_id).put_packet("card~".to_utf8() + String(JSON.print(cards.card)).to_utf8())


func _close_request(id, code, reason):
	# This is called when a client notifies that it wishes to close the connection,
	# providing a reason string and close code.
	print_debug("Client %d disconnecting with code: %d, reason: %s" % [id, code, reason])

func _disconnected(id, was_clean = false):
	# This is called when a client disconnects, "id" will be the one of the
	# disconnecting client, "was_clean" will tell you if the disconnection
	# was correctly notified by the remote peer before closing the socket.
	print_debug("Client %d disconnected, clean: %s" % [id, str(was_clean)])
	is_connected = false

func _on_data(id):
	# Print the received packet, you MUST always use get_peer(id).get_packet to receive data,
	# and not get_packet directly when not using the MultiplayerAPI.
	var pkt = _server.get_peer(id).get_packet().get_string_from_utf8()
	print_debug("Got data from client %d: %s ... echoing" % [id, pkt])
	if "draw" == pkt.left(5):
		$decks.get_child(0)._draw_card()
	if "play~" == pkt.left(5):
		for card_scene in $camera/player_hand.get_children():
			print_debug(pkt.substr(5,pkt.length()-5) + " =? " +  card_scene.card["top_left"])
			if pkt.substr(5,pkt.length()-5) == card_scene.card["top_left"]:
				card_scene.play_card()
				break
	if "deck_top~" == pkt.left(9):
		for card_scene in $camera/player_hand.get_children():
			print_debug(pkt.substr(9,pkt.length()-9) + " =? " +  card_scene.card["top_left"])
			if pkt.substr(9,pkt.length()-9) == card_scene.card["top_left"]:
				$decks.get_child(0).place_card_in_deck(card_scene.card,"top")
				card_scene.queue_free()
				break
	if "deck_bottom~" == pkt.left(12):
		for card_scene in $camera/player_hand.get_children():
			print_debug(pkt.substr(12,pkt.length()-12) + " =? " +  card_scene.card["top_left"])
			if pkt.substr(12,pkt.length()-12) == card_scene.card["top_left"]:
				$decks.get_child(0).place_card_in_deck(card_scene.card,"bottom")
				card_scene.queue_free()
				break
	
		

func _process(_delta):
	# Call this in _process or _physics_process.
	# Data transfer, and signals emission will only happen when calling this function.
	_server.poll()



	
#func get_image_from_google(search_term: String):
#	var http_request = HTTPRequest.new()
#	add_child(http_request)
#	http_request.connect("request_completed", self, "_http_request_completed")
#
#	#var http_error = http_request.request("https://upload.wikimedia.org/wikipedia/commons/thumb/e/e9/Felis_silvestris_silvestris_small_gradual_decrease_of_quality.png/200px-Felis_silvestris_silvestris_small_gradual_decrease_of_quality.png")
#	var http_error = http_request.request("https://www.bing.com/images/search?q=llanowar")
#	if http_error != OK:
#		print_debug("An error occurred in the HTTP request.")
#
#
#func _http_request_completed(result, response_code, headers, body):
#	var parser: XMLParser = XMLParser.new()
#	parser.open_buffer(body)
#
#	parsedString: String = parser.
#	var http_request = HTTPRequest.new()
#	add_child(http_request)
#	http_request.connect("request_completed", self, "_load_image_from_http")
#	var http_error = http_request.request(parsedString)
#	if http_error != OK:
#		print_debug("An error occurred in the HTTP request.")
#
#
#func _load_image_from_http(result, response_code, header,body):
#	var image = Image.new()
#	var image_error = image.load_png_from_buffer(body)
#	if image_error != OK:
#		print_debug("An error occurred while trying to display the image.")
#	var texture = ImageTexture.new()
#	texture.create_from_image(image)
#	$Sprite.texture = texture
