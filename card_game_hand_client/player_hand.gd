extends Control


var hand_array : Array = []

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	var _connected = get_tree().root.connect("size_changed", self, "_on_viewport_resized")
	_on_viewport_resized()
	setup_client()
	


func _on_viewport_resized() -> void:
	var viewport_size = get_viewport().size
	$card_list.rect_size = viewport_size * Vector2(1,0.5)
	$card_preview.rect_position.y = $card_list.rect_size.y+5
	$card_preview/top_right.rect_position.x = viewport_size.x-65
	$card_preview/bottom.rect_position.y = $card_preview/top_right.rect_size.y + 10
	
	$card_preview/middle_scroller.rect_position = Vector2(10, $card_preview/bottom.rect_position.y + $card_preview/bottom.rect_size.y + 20)
	$card_preview/middle_scroller.rect_size = Vector2(viewport_size.x - 20, viewport_size.y - \
		($card_preview/middle_scroller.rect_position.y + $actions_list.rect_size.y + $card_list.rect_size.y + 40 ))
	
	$card_preview/middle_scroller/middle.rect_min_size = $card_preview/middle_scroller.rect_size - Vector2(10,10)
	
	$actions_list.rect_position = Vector2(viewport_size.x/2 - $actions_list.rect_size.x/2, viewport_size.y - ($actions_list.rect_size.y + 5))


func _on_play_button_pressed() -> void:
	action_on_card("play")

func _on_deck_bottom_button_pressed() -> void:
	action_on_card("deck_bottom")

func _on_deck_top_button_pressed() -> void:
	action_on_card("deck_top")

func action_on_card(action:String):
	
	for card_num in $card_list.get_selected_items():
		for i in range(0,hand_array.size()):
			if hand_array[i]["top_left"] == $card_list.get_item_text(card_num):
				_client.get_peer(1).put_packet(action.to_utf8() + "~".to_utf8() + hand_array[i]["top_left"].to_utf8())
				hand_array.remove(i)
				$card_list.remove_item(i)
				break




func _on_draw_button_pressed() -> void:
	print_debug("sending packet...")
	_client.get_peer(1).put_packet("draw".to_utf8())


func _on_card_list_item_selected(_index: int) -> void:
	if "top_left" in hand_array[_index]:
		$card_preview/top_left.text = hand_array[_index]["top_left"]
	if "top_right" in hand_array[_index]:
		$card_preview/top_right.text = hand_array[_index]["top_right"]
	if "middle" in hand_array[_index]:
		$card_preview/middle_scroller/middle.text = hand_array[_index]["middle"]
	var bottom:String = ""
	if "bottom_left" in hand_array[_index]:
		bottom += hand_array[_index]["bottom_left"]
	if "bottom_right" in hand_array[_index]:
		bottom += hand_array[_index]["bottom_right"]
	$card_preview/bottom.text = bottom
	pass


export var websocket_url = "ws://localhost:9080/test"

# Our WebSocketClient instance
var _client = WebSocketClient.new()

func setup_client():
	# Connect base signals to get notified of connection open, close, and errors.
	_client.connect("connection_closed", self, "_closed")
	_client.connect("connection_error", self, "_closed")
	_client.connect("connection_established", self, "_connected")
	# This signal is emitted when not using the Multiplayer API every time
	# a full packet is received.
	# Alternatively, you could check get_peer(1).get_available_packets() in a loop.
	_client.connect("data_received", self, "_on_data")
	# Initiate connection to the given URL.
	var err = _client.connect_to_url(websocket_url, ["my-protocol"],false)
	if err != OK:
		print_debug("Unable to connect")
		set_process(false)
	else:
		print_debug("connected")

func _closed(was_clean = false):
	# was_clean will tell you if the disconnection was correctly notified
	# by the remote peer before closing the socket.
	print_debug("Closed, clean: ", was_clean)
	set_process(false)

func _connected(proto = ""):
	# This is called on connection, "proto" will be the selected WebSocket
	# sub-protocol (which is optional)
	print_debug("Connected with protocol: ", proto)
	# You MUST always use get_peer(1).put_packet to send data to server,
	# and not put_packet directly when not using the MultiplayerAPI.
	_client.get_peer(1).put_packet("Test packet".to_utf8())


func _on_data():
	# Print the received packet, you MUST always use get_peer(1).get_packet
	# to receive data from server, and not get_packet directly when not
	# using the MultiplayerAPI.
	var data:String  = String(_client.get_peer(1).get_packet().get_string_from_utf8())
	print_debug("Got data from server: "+ data)
	if "card~" == data.left(5):
		print_debug(data.substr(5,data.length()-5))
		hand_array.append(JSON.parse(data.substr(5,data.length()-5)).result)
		$card_list.add_item(hand_array[hand_array.size()-1]["top_left"])
		#print_debug("drew: " + hand_array[0]["top_left"])

func _process(_delta):
	# Call this in _process or _physics_process. Data transfer, and signals
	# emission will only happen when calling this function.
	_client.poll()
	


