extends Node2D


func _ready() -> void:
	set_base_color()

func on_click():
	print_debug("I've been clicked! piece")

func set_base_color(color = Color(1,1,1,1)):
	$PieceSprite.modulate = color
