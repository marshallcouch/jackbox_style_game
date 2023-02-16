extends Node2D

var decks: Array = []
var discard_pile: Array = []
var player_hands: Array = []

onready var _discard_pile_list = $Cards/DiscardPile


func _ready() -> void:
	_setup_deck()
	_setup_start_menu()
	print("done")
	


func _on_viewport_size_changed():
	# Do whatever you need to do when the window changes!
	_setup_start_menu()

func _input(event) -> void:
	if event.is_action_pressed("ui_menu"):
		$Controls/StartMenu.show()
			
func _setup_start_menu():
	var start_panel = $Controls/StartMenu/StartMenuPanel
	start_panel.rect_size = get_viewport().size
	var vbox = $Controls/StartMenu/StartMenuPanel/StartMenuVbox
	vbox.rect_size \
		= Vector2(get_viewport().size.x *.8 \
		,get_viewport().size.y  )
	vbox.rect_position \
		= Vector2(get_viewport().size.x *.1,0)
	for button in vbox.get_children():
		button.rect_min_size.y = 40

	

	
#this _setup deck calls a function to create a normal deck of playing cards
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

func discard(card_to_discard:Dictionary) -> void:
	_discard_pile_list.add_item(card_to_discard["name"])
	_discard_pile_list.move_item(discard_pile.size(),0)
	discard_pile.push_front(card_to_discard)

func play_card(card_to_play:Dictionary) -> void:
	pass
	
func _on_DebugButton_pressed() -> void:
	discard(draw_card())
	


func _on_start_menu_button_pressed(extra_arg_0: String) -> void:
	if extra_arg_0 == "start_game":
		pass
	elif extra_arg_0 == "join_game":
		pass
	elif extra_arg_0 == "return_to_game":
		$Controls/StartMenu.hide()
		pass
	elif extra_arg_0 == "quit":
		get_tree().quit()
		pass
