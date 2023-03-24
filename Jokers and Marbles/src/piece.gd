extends Node2D
class_name Piece
const ICONS_IN_FOLDER = 20
@onready var base_sprite = $PieceSprite
@onready var icon_sprite = $PieceIconSprite
@onready var piece_base = $PieceBase
var piece_id = null

func _ready() -> void:
	piece_id = uuid.v4()

func on_click():
	print_debug("I've been clicked! piece")

func set_base_color(color = Color(1,1,1,1)) -> Piece:
	base_sprite.modulate = color
	return self

func set_icon_color (color = Color(0,0,0,1))-> Piece:
	icon_sprite.modulate = color
	return self

func scale_piece(new_scale:Vector2 = Vector2(1,1)) -> Piece:
	scale = new_scale
	return self

func set_icon(index_of_image:int  = 1) -> Piece:
	var dir = DirAccess.open("res://assets/sprites/piece_icon/")
	if dir.file_exists(str(index_of_image) + ".png"):
		icon_sprite.texture = \
		load("res://assets/sprites/piece_icon/" + str(index_of_image) + ".png")
	return self
	
