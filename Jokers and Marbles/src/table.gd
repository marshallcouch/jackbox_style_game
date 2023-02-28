extends Node2D

var decks: Array = []
var player_hands: Array = []
onready var start_menu = $Controls/StartMenu
onready var start_panel = $Controls/StartMenu/StartMenuPanel
onready var start_menu_vbox = $Controls/StartMenu/StartMenuPanel/StartMenuVbox
onready var discard_pile = $Cards/DiscardArea
onready var cards_in_hand_list = $Controls/Camera/HandCanvas/HandContainer/CardsInHand
onready var hand_container = $Controls/Camera/HandCanvas/HandContainer
onready var hand_panel = $Controls/Camera/HandCanvas/HandPanel
onready var hand_canvas = $Controls/Camera/HandCanvas
onready var pieces = $Pieces
onready var camera = $Controls/Camera
var networking:Networking = Networking.new()


func _ready() -> void:
	#var _connected = get_tree().root.connect("size_changed", self, "_on_viewport_resized")
	_setup_deck()
	add_child(networking)
	print_debug("done")
	camera.connect("show_hand",self,"_show_hand")
	camera.connect("menu",self,"_show_start_menu")
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
			var piece = create_piece(color_array[i],Color(1,1,1),i+1,Vector2(1,1))
			piece.position = Vector2(-100+(1+i)*20,-100+(1+j)*20)


func _show_start_menu():
	if get_viewport().size.x *.8 != start_menu_vbox.rect_size.x:
		start_panel.rect_size = get_viewport().size
		start_menu_vbox.rect_size \
			= Vector2(get_viewport().size.x *.8 \
			,get_viewport().size.y  )
		start_menu_vbox.rect_position \
			= Vector2(get_viewport().size.x *.1,0)
	start_menu.show()


func create_piece(base_color = Color(1,1,1), icon_color = Color(0,0,0), icon:int = 1, piece_scale:Vector2 = Vector2(1,1)) -> Object:
	var piece = load("res://scenes/pieces/Piece.tscn").instance()
	pieces.add_child(piece)
	piece.set_base_color(base_color)
	piece.set_icon_color(icon_color)
	piece.set_icon_image(icon)
	piece.scale_piece(piece_scale)
	return piece


func _input(event) -> void:
	if event.is_action_pressed("ui_menu"):
		start_menu.show()


func _setup_deck() -> void:
	decks.append(Utils.setup_standard_deck(true,true))


func _setup_players(num_players: int = 1) -> void:
	player_hands.clear()
	var empty_hand:Array
	for i in num_players:
		empty_hand = []
		player_hands.append(empty_hand)


func _place_card_in_players_hand(player, card) -> void:
	player_hands[player].append(card)


func draw_card(deck_to_draw_from: String = "") -> Dictionary:
	if deck_to_draw_from != "":
		for deck in decks:
			if "name" in deck:
				if deck_to_draw_from == deck["name"]:
					return deck["cards"].pop_front()
	return decks[0]["cards"].pop_front()


func _show_hand():
	#if get_viewport().size.x *.9 != hand_panel.rect_size.x:
	hand_container.set_position(Vector2(get_viewport().size.x *.05,get_viewport().size.y *.05 ))
	hand_container.set_size( Vector2(get_viewport().size.x *.9,get_viewport().size.y *.5 ))
	cards_in_hand_list.rect_min_size = Vector2(get_viewport().size.x *.9,get_viewport().size.y *.45)
	hand_panel.set_position(hand_container.rect_position)
	hand_panel.rect_size = Vector2(get_viewport().size.x *.9,get_viewport().size.y *.55 )
	if hand_canvas.visible:
		hand_canvas.hide()
	else:
		hand_canvas.show()


func play_card(card_to_play:Dictionary) -> void:
	pass


func _on_DebugButton_pressed() -> void:
	discard_pile.discard(draw_card())


func _on_start_menu_button_pressed(button_pressed: String) -> void:
	if button_pressed == "start_game":
		networking.start_game()
		_set_start_button_visibility(false)
	elif button_pressed == "join_game":
		networking.join_game()
		_set_start_button_visibility(false)
	elif button_pressed == "disconnect":
		networking.disconnect_game(0)
		_set_start_button_visibility(true)
		return
	elif button_pressed == "return_to_game":
		$Controls/StartMenu.hide()
		return
	elif button_pressed == "quit":
		get_tree().quit()
		return


func _set_start_button_visibility(visible:bool = true):
	if visible:
		$Controls/StartMenu/StartMenuPanel/StartMenuVbox/JoinGameButton.show()
		$Controls/StartMenu/StartMenuPanel/StartMenuVbox/StartGameButton.show()
		$Controls/StartMenu/StartMenuPanel/StartMenuVbox/DisconnectGameButton.hide()
	else:
		$Controls/StartMenu/StartMenuPanel/StartMenuVbox/JoinGameButton.hide()
		$Controls/StartMenu/StartMenuPanel/StartMenuVbox/StartGameButton.hide()
		$Controls/StartMenu/StartMenuPanel/StartMenuVbox/DisconnectGameButton.show()
