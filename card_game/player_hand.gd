extends CanvasLayer



# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass



func _on_player_hand_child_entered_tree(node: Node) -> void:
	if node == self:
		print_debug("card was drawn...fuck")
	pass # Replace with function body.
