extends  MarginContainer


# Declare member variables here. Examples:
# var a: int = 2
# var b: String = "text"
signal draw_card_from_deck(card_name)

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass

func _set_label(text):
	$card_name_label.text = " " + text
# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta: float) -> void:
#	pass


func _on_card_draw_button_pressed() -> void:
	emit_signal("draw_card_from_deck",$card_name_label.text.trim_prefix(" ")) # Replace with function body.
