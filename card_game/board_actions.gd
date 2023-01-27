extends Node2D
class_name Board

# Declare member variables here. Examples:
# var a: int = 2
# var b: String = "text"

# Called when the node enters the scene tree for the first time.
func _ready() -> void:

	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta: float) -> void:
#	pass


func _on_deck_draw_card(card_object) -> void:
	print_debug("drawn card:" + card_object["TopLeft"])
	var drawn_card = load("res://cards/card.tscn").instance()
	drawn_card.set_card(card_object)
	drawn_card.position.x = $deck.position.x-250
	drawn_card.position.y= $deck.position.y
	add_child(drawn_card)
	drawn_card.connect("place_card_back_in_deck",self,"_put_card_in_deck")
	pass # Replace with function body.

func _put_card_in_deck(card,location):
	$deck._place_card_in_deck(card,location)


func _on_token_generator_pressed() -> void:
	var new_counter = load("res://cards/counter.tscn").instance()
	new_counter.position = $token_position.position
	new_counter.z_index = 1000
	self.add_child(new_counter)
	pass # Replace with function body.
