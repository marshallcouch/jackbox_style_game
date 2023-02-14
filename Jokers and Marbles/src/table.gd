extends Node2D

var decks: Array = []
var discard_pile: Array = []
var player_hands: Array = []

onready var _discard_pile_list = $Cards/DiscardPile


func _ready() -> void:
	_setup_deck()
	print("done")

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
