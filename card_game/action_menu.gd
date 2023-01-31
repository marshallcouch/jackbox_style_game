extends PopupMenu




# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	add_item("Load Deck(s)") 
	add_item("Clear Decks")
	add_item("Create Token/Counter")
	add_item("Clear Tokens/Counters")
	add_item("Close Menu")




func _on_action_menu_button_pressed() -> void:
	show()


func _on_action_menu_index_pressed(index: int) -> void:
	if index == 0: #load deck
		$deck_dialog.popup()
		
	if index == 1: #Clear decks
		for nodes in get_node("/root/board/decks").get_children():
			get_node("/root/board/decks").remove_child(nodes)
		
	elif index == 2: #Create Token/Counter
		var new_counter = load("res://cards/counter.tscn").instance()
		new_counter.z_index = 1000
		get_node("/root/board/counters").add_child(new_counter)
		
	elif index == 3: #Create Token/Counter
		for nodes in get_node("/root/board/counters").get_children():
			get_node("/root/board/counters").remove_child(nodes)

