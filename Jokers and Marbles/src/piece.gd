extends Node2D


func _ready() -> void:
	set_base_color()
	set_icon_color()
	scale_piece(Vector2(.5,.5))

func on_click():
	print_debug("I've been clicked! piece")

func set_base_color(color = Color(1,1,1,1)):
	$PieceSprite.modulate = color

func set_icon_color (color = Color(0,0,0,1)):
	$PieceIconSprite.modulate = color

func scale_piece(new_scale:Vector2 = Vector2(1,1)):
	$PieceBase.scale = new_scale
	$PieceSprite.scale = new_scale
	$PieceIconSprite.scale = new_scale
