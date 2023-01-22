extends Container


# Declare member variables here. Examples:
# var a: int = 2
# var b: String = "text"



# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$top_left_label.text = "t"
	$top_right_label.text = "t"
	$middle_label.text = "t\n\n\n\n\n\nt"
	$bottom_left_label.text = "t"
	$bottom_right_label.text = "t"
	$card_image.texture = load("res://assets/cards/energy.png")
	if $card_image.texture.get_height() > $card_image.texture.get_width():
		$card_image.scale *= 100.0/$card_image.texture.get_height()
	else: 
		$card_image.scale *= 100.0/$card_image.texture.get_width()
	$card_image.offset.x = 125/$card_image.scale.x
	$card_image.offset.y = ($card_image.texture.get_height()*$card_image.scale.y)+180
	$card_image.centered = true
	print($card_image.texture.get_height())
	print($card_image.texture.get_width())
	
	
	
