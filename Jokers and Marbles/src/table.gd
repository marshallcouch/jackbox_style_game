extends Node2D

var decks: Array = []
var discard_pile: Array = []
var player_hands: Array = []
onready var start_panel = $Controls/StartMenu/StartMenuPanel
onready var start_menu_vbox = $Controls/StartMenu/StartMenuPanel/StartMenuVbox
onready var discard_pile_list = $Cards/DiscardPile
onready var cards_in_hand_list = $Controls/Camera/HandCanvas/HandContainer/CardsInHand
onready var hand_container = $Controls/Camera/HandCanvas/HandContainer
onready var hand_panel = $Controls/Camera/HandCanvas/HandPanel
onready var hand_canvas = $Controls/Camera/HandCanvas
var networking:Networking = Networking.new()


func _ready() -> void:
	var _connected = get_tree().root.connect("size_changed", self, "_on_viewport_resized")
	_setup_deck()
	_on_viewport_resized()
	add_child(networking)
	print_debug("done")
	$Controls/Camera.connect("show_hand",self,"_show_hand")
	$Controls/Camera.connect("menu",self,"_show_start_menu")


func _show_start_menu():
	$Controls/StartMenu.show()


func _on_viewport_resized():
	# Do whatever you need to do when the window changes!
	start_panel.rect_size = get_viewport().size
	start_menu_vbox.rect_size \
		= Vector2(get_viewport().size.x *.8 \
		,get_viewport().size.y  )
	start_menu_vbox.rect_position \
		= Vector2(get_viewport().size.x *.1,0)
		

	hand_container.set_position(Vector2(get_viewport().size.x *.05,get_viewport().size.y *.05 ))
	hand_container.set_size( Vector2(get_viewport().size.x *.9,get_viewport().size.y *.5 ))
	cards_in_hand_list.rect_min_size = Vector2(get_viewport().size.x *.9,get_viewport().size.y *.5)
	hand_panel.set_position(hand_container.rect_position)
	hand_panel.rect_size = Vector2(get_viewport().size.x *.9,get_viewport().size.y *.6 )

func _input(event) -> void:
	if event.is_action_pressed("ui_menu"):
		$Controls/StartMenu.show()


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
	if hand_canvas.visible:
		hand_canvas.hide()
	else:
		hand_canvas.show()


func discard(card_to_discard:Dictionary) -> void:
	discard_pile_list.add_item(card_to_discard["name"])
	discard_pile_list.move_item(discard_pile.size(),0)
	discard_pile.push_front(card_to_discard)


func play_card(card_to_play:Dictionary) -> void:
	pass


func _on_DebugButton_pressed() -> void:
	discard(draw_card())


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
