extends Node2D

var decks: Array = []
var players: Array[Player] = []
@onready var start_menu = $Controls/StartMenu
@onready var start_panel = $Controls/StartMenu/StartMenuPanel
@onready var start_menu_vbox = $Controls/StartMenu/StartMenuPanel/StartMenuVbox
@onready var discard_pile = $Cards/DiscardArea
@onready var cards_in_hand_list = $Controls/Camera3D/HandCanvas/HandContainer/CardsInHand
@onready var hand_container = $Controls/Camera3D/HandCanvas/HandContainer
@onready var hand_panel = $Controls/Camera3D/HandCanvas/HandPanel
@onready var hand_canvas = $Controls/Camera3D/HandCanvas
@onready var pieces = $Pieces
@onready var camera = $Controls/Camera3D
@onready var networking:Networking = Networking.new()


class Player:
	var id:String
	var hand: Array[Dictionary]
	var name:String
	var stream: StreamPeerTCP
	func set_id():
		id = uuid.v4()
		
func _ready() -> void:
	#var _connected = get_tree().root.connect("size_changed",Callable(self,"_on_viewport_resized"))
	add_child(networking)
	_setup_deck()
	networking.connect("data_received",Callable(self,"_data_received"))
	networking.connect("peer_connected",Callable(self,"_player_connected"))
	networking.connect("peer_disconnected",Callable(self,"_player_disconnected"))
	camera.connect("show_hand",Callable(self,"_show_hand"))
	camera.connect("menu",Callable(self,"_show_start_menu"))
	create_pieces()


func _show_start_menu():
	if get_viewport().size.x *.8 != start_menu_vbox.size.x:
		start_panel.size = get_viewport().size
		start_menu_vbox.size \
			= Vector2(get_viewport().size.x *.8 \
			,get_viewport().size.y  )
		start_menu_vbox.position \
			= Vector2(get_viewport().size.x *.1,0)
	if start_menu.visible:
		start_menu.hide()
	else:
		start_menu.show()

func create_pieces():
	var color_array = []
	color_array.append(Color(0,0,0))
	color_array.append(Color(1,0,0))
	color_array.append(Color(0,1,0))
	color_array.append(Color(1,1,0))
	color_array.append(Color(0,0,1))
	color_array.append(Color(1,0,1))
	color_array.append(Color(0,1,1))
	color_array.append(Color(1,1,1))
	for i in 8:
		for j in 5:
			var piece = load("res://scenes/pieces/Piece.tscn").instantiate()
			pieces.add_child(piece)
			piece.set_base_color(color_array[i]).set_icon_color(Color(1,1,1)).scale_piece(Vector2(1,1)).set_icon(i+1)
			piece.position = Vector2(-100+(1+i)*20,-100+(1+j)*20)


func _on_DebugButton_pressed() -> void:
	#discard_pile.discard(server_draw_card())
	pass

@onready var server_label = $Controls/StartMenu/StartMenuPanel/StartMenuVbox/ServerLabel
@onready var server_text_box = $Controls/StartMenu/StartMenuPanel/StartMenuVbox/ServerTextBox
@onready var player_name_label = $Controls/StartMenu/StartMenuPanel/StartMenuVbox/PlayerNameLabel
@onready var player_name_text_box = $Controls/StartMenu/StartMenuPanel/StartMenuVbox/PlayerNameTextBox
@onready var connect_button = $Controls/StartMenu/StartMenuPanel/StartMenuVbox/ConnectGameButton

func _on_start_menu_button_pressed(button_pressed: String) -> void:
	if button_pressed == "start_game":
		_set_start_button_visibility(false)
		start_menu.hide()
		_setup_server()
	elif button_pressed == "join_game":
		if server_label.visible:
			server_label.hide()
			server_text_box.hide()
			player_name_label.hide()
			player_name_text_box.hide()
			connect_button.hide()
		else:
			server_label.show()
			server_text_box.show()
			player_name_label.show()
			player_name_text_box.show()
			connect_button.show()
	elif button_pressed == "connect":
		server_label.hide()
		server_text_box.hide()
		player_name_label.hide()
		player_name_text_box.hide()
		connect_button.hide()
		start_menu.hide()
		_set_start_button_visibility(false)
		_setup_client()
	elif button_pressed == "disconnect":
		networking.stop_game()
		_set_start_button_visibility(true)
	elif button_pressed == "return_to_game":
		start_menu.hide()
	elif button_pressed == "quit":
		get_tree().quit()
	

@onready var join_button = $Controls/StartMenu/StartMenuPanel/StartMenuVbox/JoinGameButton
@onready var start_game_button = $Controls/StartMenu/StartMenuPanel/StartMenuVbox/StartGameButton
@onready var disconnect_game_button = $Controls/StartMenu/StartMenuPanel/StartMenuVbox/DisconnectGameButton
func _set_start_button_visibility(visible:bool = true):
	if visible:
		join_button.show()
		start_game_button.show()
		disconnect_game_button.hide()
	else:
		join_button.hide()
		start_game_button.hide()
		disconnect_game_button.show()


func _setup_server():
	networking.start_server()


func _setup_client():
	networking.join_game(server_text_box.text)

func _input(event) -> void:
	if event.is_action_pressed("ui_menu"):
		_show_start_menu()


func _setup_deck() -> void:
	decks.append(Utils.setup_standard_deck(true,true))


func _player_connected(peer_id):
	var new_player = Player.new()
	new_player.id = peer_id
	players.append(new_player)


func _player_disconnected(peer_id):
	for i in players.size():
		if players[i] == peer_id:
			players.remove_at(i)


func _update_pieces(pieceid, position:Vector2):
	pass
	
func _on_hand_button_pressed(action):
	match action:
		"play":
			pass
		"draw":
			if networking.is_client:
				var d:Dictionary = {"action":"draw","deck":""}
				networking.send_packet(JSON.stringify(d))
		"discard":
			if networking.is_client:
				var selected_card_idx:int = -1
				for c in cards_in_hand_list.get_selected_items():
					selected_card_idx = c
				var selected_card: String = cards_in_hand_list.get_item_text(selected_card_idx)
				if selected_card_idx > -1:
					cards_in_hand_list.remove_item(selected_card_idx)
				var d:Dictionary = {"action":"discard","card":selected_card}
				networking.send_packet(JSON.stringify(d))
		"close":
			hand_canvas.hide()
	
func _data_received(message:String,peer_id):
	var message_dict = {}
	message_dict = JSON.parse_string(message)
	if !message_dict.has("action"):
		return
	if message_dict["action"] == "draw":
		_draw_card(message_dict,peer_id)
	if message_dict["action"] == "discard":
		_discard_card(message_dict,peer_id)
	if message_dict["action"] == "piece_update":
		pass
		
func _draw_card(message_dict:Dictionary,peer_id):
	if networking.is_server:
		var card = ""
		if message_dict["deck"] != "":
			for deck in decks:
				if "name" in deck:
					if message_dict["deck"] == deck["name"]:
						card = deck["cards"].pop_front()
		else:
			card = decks[0]["cards"].pop_front()
		for player in players:
			if player.id == peer_id:
				player.hand.append(card)
		var response:Dictionary = {"action":"draw", "card":card}
		networking.send_packet(JSON.stringify(response),peer_id)
	elif networking.is_client:
		cards_in_hand_list.add_item(message_dict["card"]["name"])

func _discard_card(message_dict:Dictionary,peer_id):
	if networking.is_server:
		for player in players:
			var idx:int = -1
			if player.id == peer_id:
				for i in player.hand.size():
					#print(message_dict["card"] + " =? " + player.hand[i]["name"])
					if message_dict["card"] == player.hand[i]["name"]:
						idx = i
						#print ("match found!")
						break
				if idx > -1:
					discard_pile.discard(player.hand.pop_at(idx))
	var response:Dictionary = {"status":"success", "requested_action":"discard"}
	networking.send_packet(JSON.stringify(response),peer_id)
		


func play_card(card_to_play:Dictionary) -> void:
	pass


func _show_hand():
	#if get_viewport().size.x *.9 != hand_panel.size.x:
	hand_container.set_position(Vector2(get_viewport().size.x *.05,get_viewport().size.y *.05 ))
	hand_container.set_size( Vector2(get_viewport().size.x *.9,get_viewport().size.y *.5 ))
	cards_in_hand_list.custom_minimum_size = \
	Vector2(get_viewport().size.x *.9,get_viewport().size.y *.45)
	
	hand_panel.set_position(hand_container.position)
	hand_panel.size = Vector2(get_viewport().size.x *.9,get_viewport().size.y *.55 )
	if hand_canvas.visible:
		hand_canvas.hide()
	else:
		hand_canvas.show()




	
