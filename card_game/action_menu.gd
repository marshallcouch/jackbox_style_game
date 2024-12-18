extends PopupMenu


signal json_pasted(json_text)

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	add_item("Load Deck(s)") 
	add_item("Clear Decks and Cards")
	add_item("Create Token/Counter")
	add_item("Clear Tokens/Counters")
	add_item("About")
	add_item("Close Menu")
	self.connect("json_pasted",get_node("/root/board"),"_on_action_menu_json_pasted")
	




func _on_action_menu_button_pressed() -> void:
	show()


func _on_action_menu_index_pressed(index: int) -> void:
	if index == 0: #load deck
		$deck_json_popup.popup()
		
	if index == 1: #Clear decks
		for nodes in get_node("/root/board/decks").get_children():
			get_node("/root/board/decks").remove_child(nodes)
		for nodes in get_node("/root/board/cards").get_children():
			get_node("/root/board/cards").remove_child(nodes)
		for nodes in get_node("/root/board/camera/player_hand").get_children():
			get_node("/root/board/camera/player_hand").remove_child(nodes)
		
	elif index == 2: #Create Token/Counter
		var new_counter = load("res://cards/counter.tscn").instance()
		new_counter.z_index = 1000
		get_node("/root/board/counters").add_child(new_counter)
		
	elif index == 3: #clear Token/Counter
		for nodes in get_node("/root/board/counters").get_children():
			get_node("/root/board/counters").remove_child(nodes)

	elif index == 4: #Create Token/Counter
		get_parent().find_node("about_popup").popup()
		

func _on_confirm_button_pressed() -> void:
	emit_signal("json_pasted",$deck_json_popup/json_text_edit.text)
	$deck_json_popup.hide()
