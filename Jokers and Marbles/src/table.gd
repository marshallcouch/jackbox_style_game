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
@onready var networking = $Networking


class Player:
	var id:String
	var hand: Array[String]
	var name:String
	var stream: StreamPeerTCP
	func set_id():
		id = uuid.v4()
		
		
func _ready() -> void:
	#var _connected = get_tree().root.connect("size_changed",Callable(self,"_on_viewport_resized"))
	_setup_deck()
	#networking.connect("data_received",Callable(self,"_update_from_network_player"))
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
		




func _input(event) -> void:
	if event.is_action_pressed("ui_menu"):
		_show_start_menu()


func _setup_deck() -> void:
	decks.append(Utils.setup_standard_deck(true,true))


func _place_card_in_players_hand(player_id, card) -> void:
	for player in players:
		if player.id == player_id:
			player.hand.append(card)


func _player_connected(peer_id):
	var new_player = Player.new()
	new_player.id = peer_id
	players.append(new_player)


func _player_disconnected(peer_id):
	for i in players.size():
		if players[i] == peer_id:
			players.remove_at(i)


func server_draw_card(deck_to_draw_from: String = "") -> Dictionary:
	if deck_to_draw_from != "":
		for deck in decks:
			if "name" in deck:
				if deck_to_draw_from == deck["name"]:
					return deck["cards"].pop_front()
	return decks[0]["cards"].pop_front()


func _client_draw_card(deck_to_draw_from: String = ""):
	pass


func _client_move_piece(pieceid, position:Vector2):
	pass
	
func _message_received(peer_id: int, message:Dictionary):
	if message["action"] == "draw":
		server_draw_card(message["deck"])
		

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


func play_card(card_to_play:Dictionary) -> void:
	pass


func _on_DebugButton_pressed() -> void:
	discard_pile.discard(server_draw_card())


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
	#networking.connect("data_received",Callable(self,"_update_table"))
	networking.join_game(server_text_box.text)


func _update_from_network_player(updated_info: Dictionary):
	print("got data!")
	pass
	
func process(delta):
	pass


func _on_hand_button_pressed(action):
	match action:
		"play":
			pass
		"draw":
			pass
		"discard":
			pass
		"close":
			hand_canvas.hide()
		
