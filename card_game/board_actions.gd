extends Node2D
class_name Board

func _ready() -> void:
	pass


func _on_deck_draw_card(card_object) -> void:
	print_debug("drawn card:" + card_object["TopLeft"])
	var drawn_card = load("res://cards/card.tscn").instance()
	drawn_card.set_card(card_object)
	drawn_card.position.x = $deck.position.x-250
	drawn_card.position.y= $deck.position.y
	add_child(drawn_card)
	drawn_card.connect("place_card_back_in_deck",self,"_put_card_in_deck")


func _put_card_in_deck(card,location):
	$deck._place_card_in_deck(card,location)

func _on_deck_dialog_file_selected(path: String) -> void:
	var new_deck = load("res://cards/card_deck.tscn").instance()
	new_deck.load_deck(path)
	$decks.add_child(new_deck)
