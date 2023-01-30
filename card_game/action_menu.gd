extends PopupMenu




# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	add_item("Load Deck")
	add_item("Clear Deck")
	add_item("Create Token/Counter")
	add_item("Close Menu")




func _on_action_menu_button_pressed() -> void:
	show()


func _on_action_menu_index_pressed(index: int) -> void:
	if index == 0: #load deck
		$deck_dialog.popup()
		
	if index == 1: #Clear decks
		pass
		
	elif index == 2: #Create Token/Counter
		var new_counter = load("res://cards/counter.tscn").instance()
		new_counter.z_index = 1000
		get_node("/root/board").add_child(new_counter)



