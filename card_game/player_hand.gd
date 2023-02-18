extends CanvasLayer



# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass



func _on_player_hand_child_entered_tree(_node: Node) -> void:
	$"%HandCountLabel".text = String(self.get_child_count())


func _on_player_hand_child_exiting_tree(_node: Node) -> void:
	$"%HandCountLabel".text = String(self.get_child_count()-1)
