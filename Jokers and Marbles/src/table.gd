extends Node2D

var decks: Array = []

func _ready() -> void:
	_setup_deck()
	print_debug("done")

#this _setup deck calls a function to create a normal deck of playing cards
func _setup_deck() -> void:
	decks.append(Utils.setup_standard_deck(true,true))
