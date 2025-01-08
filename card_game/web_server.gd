extends Node
class_name WebServer
const SERVER_PORT = 1088
var server := TCPServer.new()
var clients: Array = []
var player_hand: Node

func start():
	# Start listening for connections
	var result = server.listen(SERVER_PORT)
	if result != OK:
		print("Failed to start server: ", result)
	else:
		print("Server started on port ", SERVER_PORT)
		
signal client_connected
func process():
	# Accept new client connections
	if server.is_connection_available():
		var client = server.take_connection()
		if client:
			clients.append(client)
			client_connected.emit()

	# Handle client requests
	for client in clients:
		if client.get_status() == StreamPeerTCP.STATUS_CONNECTED:
			if client.get_available_bytes() > 0:
				var request = client.get_utf8_string(client.get_available_bytes())
				#print("Received request:\n", request)
				_handle_request(client, request)
		else:
			clients.erase(client)
func set_hand_node(p_hand:Node):
	player_hand = p_hand

func get_cards()-> Array[Card]:
	var cards:Array[Card]
	for c:Card in player_hand.get_children():
		cards.append(c)
	return cards

func _handle_request(client: StreamPeerTCP, request: String):
	# HTML response with corrected diamond-shaped D-pad layout
	var client_id_loc:int = request.find("client=",request.length()-70)
	var client_id:String = "-1"
	var action:String = request.substr(request.find("action"))
	print(request)
	
	var body = SKELETON.replace("STYLE_CONTENT","")\
	.replace("SCRIPT_CONTENT","")\
	.replace("BODY_CONTENT",_cards_in_hand())
	
	# Ensure no extraneous characters before headers
	var response = set_headers(body)
	client.put_data(response.to_utf8_buffer())
	client.disconnect_from_host()

func _cards_in_hand() -> String:
	var cards_body:String = ""
	for card in get_cards():
		cards_body += CARD_BODY.replace("TOP_RIGHT", card.tr)\
		.replace("TOP_LEFT", card.tl)\
		.replace("MIDDLE", card.mid)\
		.replace("BOTTOM_LEFT", card.bl)\
		.replace("BOTTOM_RIGHT", card.br)
	return cards_body
		

func set_headers(body:String) -> String:
	var response = "HTTP/1.1 200 OK\r\n"
	response += "Content-Type: text/html; charset=utf-8\r\n"
	response += "Content-Length: %d\r\n" % body.length()  # Correct content length
	response += "Connection: close\r\n"
	response += "\r\n"  # End of headers
	
	# Append the body content
	response += body
	return response
const SKELETON:String = """
<html>
	<head>
		<title>Player Hand</title>
		<script>SCRIPT_CONTENT</script>
		<style>STYLE_CONTENT</style>
	<head>
	<body>
		BODY_CONTENT
	</body>
</html>
"""

const CARD_BODY:String = """
<hr/>
<p>TOP_LEFT</p>
<p>TOP_RIGHT</p>
<p>MIDDLE</p>
<p>BOTTOM_LEFT</p>
<p>BOTTOM_RIGHT</p>
<form method="POST">
	<input name="card_name" type="hidden" value="TOP_LEFT">
	<button name="action" value="play">Play</button>
	<button name="action" value="play_face_down">Play Face Down</button>
	<button name="action" value="place_top_deck">Place Top Deck</button>
	<button name="action" value="place_bottom_deck">Place Bottom Deck</button>
</form>
<hr />
"""
