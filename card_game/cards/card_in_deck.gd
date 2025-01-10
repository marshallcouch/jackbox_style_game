extends  Control
var tl:String = ""
var tr:String = ""
var mid:String = ""
var br:String = ""
var bl:String = ""
signal draw_card_from_deck(card_name)
signal view_full_card(tl,tr,mid, bl, br)
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
	
func set_card(card_object):
	if "tl" in card_object:
		tl = card_object["tl"]

	
	
	if "tr" in card_object:
		tr = card_object["tr"]

		
	if "middle" in card_object:
		mid = card_object["middle"]
		
	if "bl" in card_object:
		bl =  card_object["bl"]

		
	if "br" in card_object:
		br = card_object["br"]


func _on_preview_button_pressed():
	view_full_card.emit(tl,tr,mid,bl,br)
