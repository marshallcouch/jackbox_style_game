extends Node2D
class_name Piece
const ICONS_IN_FOLDER = 20
@onready var base_sprite = $PieceSprite
@onready var icon_sprite = $PieceIconSprite
@onready var piece_base = $PieceBase
var piece_id:String
var icon:String

var color_array = [Color(0,0,0),Color(1,0,0), Color(0,1,0), Color(1,1,0),\
Color(0,0,1),Color(1,0,1), Color(0,1,1),Color(1,1,1)]

func _init() -> void:
	piece_id = uuid.v4()

func on_click():
	print_debug("I've been clicked! piece")

func set_base_color(color_int:int = 7) -> Piece:
	base_sprite.modulate = color_array[color_int]
	return self

func set_icon_color (color_int:int = 7)-> Piece:
	icon_sprite.modulate = color_array[color_int]
	return self

func scale_piece(new_scale:Vector2 = Vector2(1,1)) -> Piece:
	scale = new_scale
	return self

func set_icon(index_of_image:int  = 1) -> Piece:
	var dir = DirAccess.open("res://assets/sprites/piece_icon/")
	if dir.file_exists(str(index_of_image) + ".png"):
		icon = "res://assets/sprites/piece_icon/" + str(index_of_image) + ".png"
		icon_sprite.texture = load(icon)
	return self
	
func set_id(new_id:String) -> Piece:
	piece_id = new_id
	return self
	
func to_dictionary() ->Dictionary:
	return \
	{"id":piece_id,\
	"base_color":str(base_sprite.modulate),\
	"icon_color":str(icon_sprite.modulate),\
	"scale":str(scale),\
	"icon": icon,\
	"position": "("+ str(self.get_global_transform().x) + "," + str(self.get_global_transform().y) + ")"
	}
	
func _to_string() -> String:
	var json_form = self.to_dictionary()
	return JSON.stringify(json_form)
	
	
