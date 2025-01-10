extends Node2D
class_name Board
var testing = true
var password:String = ""
var is_connected:bool = false
# The port we will listen to
# Our WebSocketServer instance

var client_id:int = -1


var web_server: WebServer = WebServer.new()

var click_all = false
var ignore_unclickable = true
var previous_mouse_position = Vector2()
var is_dragging:bool = false
var dragging_shape
var zoom: = Vector2(1,1)
var camera = null
#signal new_position(Vector2,String)

func _input(event):
	if event.is_action_released("ui_touch") and $camera/LargeCard.visible:
		$camera/LargeCard.hide()
	if event.is_action_released("ui_touch") and $camera/QRCode.visible:
		hide_qr_code()
	if !camera:
		setup_camera()
		
	var parameters = PhysicsPointQueryParameters2D.new()
	parameters.position = get_global_mouse_position()
	parameters.collide_with_areas = true
	# Left mouse click
	if event is InputEventMouseButton and event.pressed and event.button_index == 1: 
			#get_global_mouse_position(), 32, [], 0x7FFFFFFF, true, true
			# The last 'true' enables Area2D intersections, previous four values are all defaults
		var shapes = get_world_2d().direct_space_state.intersect_point(parameters,1) 
		is_dragging = true
		for shape in shapes:
			if shape["collider"].has_method("on_click"):
				shape["collider"].on_click()
				dragging_shape = shape["collider"]
				if !click_all and ignore_unclickable:
					break # Thus clicks only the topmost clickable
			if !click_all and !ignore_unclickable:
				break # Thus stops on the first shape
		previous_mouse_position = event.position
		
	if event is InputEventMouseButton and !event.pressed and event.button_index == 1 and is_dragging: 
		if dragging_shape:
			if dragging_shape.has_method("on_release"):
				dragging_shape.on_release()
			dragging_shape = null
		is_dragging = false
		
	if is_dragging and event is InputEventMouseMotion and dragging_shape:
		dragging_shape.position += (event.position - previous_mouse_position) / camera.zoom  
		previous_mouse_position = event.position
		
	if is_dragging and event is InputEventMouseMotion and !dragging_shape:
		camera.position -= (event.position - previous_mouse_position) / camera.zoom  
		previous_mouse_position = event.position

			
func setup_camera():
	var viewport = get_viewport()
	var camerasGroupName = "__cameras_%d" % viewport.get_viewport_rid().get_id()
	var cameras = get_tree().get_nodes_in_group(camerasGroupName)
	for cam in cameras:
		if cam is Camera2D:
			self.camera = cam

func _ready() -> void:
	_load_preloaded_deck("pokemon_lugia_deck.tres")	
	web_server.start()
	web_server.client_connected.connect(hide_qr_code)
	web_server.set_hand_node($camera/player_hand)



func display_large_card(tl:String, tr:String, mid:String, br:String, bl:String):
	$camera/LargeCard.set_card_parts(tl, tr, mid, br, bl)
	$camera/LargeCard.show()
	

func hide_qr_code():
	$camera/QRCode.hide()
	web_server.client_connected.disconnect(hide_qr_code)
	
func _on_deck_reveal_card(card_object) -> void:
	#print_debug("drawn card:" + card_object["top_left"])
	var drawn_card:Card = load("res://cards/card.tscn").instantiate()
	$cards.add_child(drawn_card)
	drawn_card.set_card(card_object)
	drawn_card.connect("place_card_back_in_deck",Callable($decks.get_child(0),"place_card_in_deck"))
	drawn_card.connect("place_card_back_in_hand",Callable(self,"_place_card_in_hand"))
	drawn_card.view_full_card.connect(display_large_card)
	var max_x = 100
	var max_y = 0
	for cards in $cards.get_children():
		if cards.position.x > max_x:
			max_x = cards.position.x
		if cards.position.y > max_y:
			max_y = cards.position.y
	drawn_card.position = Vector2(max_x + 20 ,max_y + 40)

	
func _on_deck_draw_card(card_object) -> void:
	#print_debug("drawn card:" + card_object["top_left"])
	var drawn_card:Card = load("res://cards/card.tscn").instantiate()
	drawn_card.set_card(card_object)
	_place_card_in_hand(drawn_card)
	drawn_card.connect("place_card_back_in_deck",Callable($decks.get_child(0),"place_card_in_deck"))
	drawn_card.connect("place_card_back_in_hand",Callable(self,"_place_card_in_hand"))
	drawn_card.view_full_card.connect(display_large_card)

func _place_card_in_hand(card_scene):
	var max_x = 0
	var max_y = 0
	for cards in $camera/player_hand.get_children():
		if cards.position.x > max_x:
			max_x = cards.position.x
		if cards.position.y > max_y:
			max_y = cards.position.y
	card_scene.position = Vector2(max_x + 20 ,max_y + 40)
#	if(card_scene.is_face_down()):
#		card_scene.flip()
	if card_scene.get_parent() == $cards:
		card_scene.get_parent().remove_child(card_scene)
	$camera/player_hand.add_child(card_scene)

func _load_preloaded_deck(filename: String) -> void:
	print_debug("loading...")
	var deck_file:JSON = load("res://assets/preloaded_decks/" + filename)
	var json_text = deck_file.data
	_on_action_menu_json_pasted(json_text)


func _load_deck(filename: String) -> void:
	print_debug("loading...")
	var deck_file = FileAccess.open("res://assets/preloaded_decks/" + filename,FileAccess.READ)

	_on_action_menu_json_pasted(deck_file.get_as_text())
	deck_file.close()

func _on_action_menu_json_pasted(json_text) -> void:
	var json_result =json_text
	
	var _game_name 
	if "game" in json_result:
		_game_name = String(json_result["game"])
	#print_debug(deck_result)
	var new_deck
	for deck in json_result["decks"]:
		new_deck = load("res://cards/card_deck.tscn").instantiate()
		new_deck.load_deck(String(json_result["game"]), deck["deck_name"], deck["deck"])
		new_deck.connect("draw_card",Callable(self,"_on_deck_draw_card"))
		new_deck.connect("reveal_card",Callable(self,"_on_deck_reveal_card"))
		new_deck.position.y = get_viewport().size.y/2 - 230
		new_deck.position.x = get_viewport().size.x/2 - 125 + (220 * $decks.get_child_count())
		$decks.add_child(new_deck)


func _on_close_about_window_button_pressed() -> void:
	$camera/action_panel/action_menu_button/about_popup.hide() # Replace with function body.
	

func _process(_delta):
	web_server.process()


func _on_camera_remove_qr_code():
	$camera/QRCode.hide()
