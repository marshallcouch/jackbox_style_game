extends CanvasLayer


func _on_player_hand_child_entered_tree(_node: Node) -> void:
	$"%HandCountLabel".text = str(self.get_child_count())


func _on_player_hand_child_exiting_tree(_node: Node) -> void:
	$"%HandCountLabel".text = str(self.get_child_count()-1)
