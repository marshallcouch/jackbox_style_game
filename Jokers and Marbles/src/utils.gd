class_name Utils
static func setup_standard_deck(with_jokers:bool = false,unlimited:bool = false)->Array:
	var new_deck:Array = []
	var suit_name = ""
	for i in 4:
		if i == 0:
			suit_name = "Spades"
		elif i == 1:
			suit_name = "Hearts"
		elif i == 2:
			suit_name = "Clubs"
		elif i == 3:
			suit_name = "Diamonds"
			
		for j in range(2,11):
			new_deck.append({"card_name": String(j) + " of " + suit_name})
		
		new_deck.append({"card_name": "Ace" + " of " + suit_name})
		new_deck.append({"card_name": "King" + " of " + suit_name})
		new_deck.append({"card_name": "Queen" + " of " + suit_name})
		new_deck.append({"card_name": "Jack" + " of " + suit_name})
		if with_jokers:
			new_deck.append({"card_name": "Joker"})
			new_deck.append({"card_name": "Joker"})
	
	if unlimited:
		var unlimited_deck: Array = []
		for i in 20: #20 decks seems pretty unlimited...
			new_deck.shuffle()
			unlimited_deck.append_array(new_deck)
		return unlimited_deck
	else:
		new_deck.shuffle()
		return new_deck
