extends Node2D

var is_dragging:bool = false

func _ready() -> void:
	pass

func on_click():
	print_debug("I've been clicked! piece")
	is_dragging = true
