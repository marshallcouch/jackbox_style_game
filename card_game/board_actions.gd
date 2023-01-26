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
	pass # Replace with function body.


