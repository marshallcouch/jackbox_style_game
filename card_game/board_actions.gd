extends Node2D
class_name Board
signal place_card_in_deck(card,location)

func _ready() -> void:
	pass


func _on_deck_draw_card(card_object) -> void:
	print_debug("drawn card:" + card_object["top_left"])
	var drawn_card = load("res://cards/card.tscn").instance()
	drawn_card.set_card(card_object)
	#drawn_card.position.x = $deck.position.x-250
	#drawn_card.position.y= $deck.position.y
	add_child(drawn_card)
	drawn_card.connect("place_card_back_in_deck",self,"_put_card_in_deck")


func _put_card_in_deck(card,location):
	emit_signal("place_card_in_deck",card,location)

func _on_deck_dialog_file_selected(path: String) -> void:
	var deck_file = File.new()
	deck_file.open(path,File.READ)
	var json_result = JSON.parse(deck_file.get_as_text()).result
	deck_file.close()
	var game_name = String(json_result["game"])
	#print_debug(deck_result)
	var new_deck
	for deck in json_result["decks"]:
		new_deck = load("res://cards/card_deck.tscn").instance()
		new_deck.load_deck(String(json_result["game"]), deck["deck_name"], deck["deck"])
		new_deck.connect("draw_card",self, "_on_deck_draw_card")
		
		new_deck.position.x = 300 * $decks.get_child_count()
		if deck["deck_name"] == "Main Deck":
			self.connect("place_card_in_deck",new_deck,"_place_card_in_deck")
		$decks.add_child(new_deck)
			
