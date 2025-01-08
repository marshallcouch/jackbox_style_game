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
func get_card_count() -> int:
	return player_hand.get_child_count()

func _handle_request(client: StreamPeerTCP, request: String):
	# HTML response with corrected diamond-shaped D-pad layout
	var client_id_loc:int = request.find("client=",request.length()-70)
	var client_id:String = "-1"
	var action:String = request.substr(request.find("action"))
	print(request)
	
	var body = SKELETON.replace("STYLE_CONTENT",STYLES)\
	.replace("SCRIPT_CONTENT", SCRIPTS)\
	.replace("BODY_CONTENT",_cards_in_hand())
	
	# Ensure no extraneous characters before headers
	var response = set_headers(body)
	client.put_data(response.to_utf8_buffer())
	client.disconnect_from_host()

func _cards_in_hand() -> String:
	var cards_body:String = "<p>Count: " + str(get_card_count()) + "</p>"
	for card in get_cards():
		cards_body += CARD_BODY.replace("TOP_RIGHT", card.tr)\
		.replace("TOP_LEFT", card.tl)\
		.replace("MIDDLE", card.mid)\
		.replace("BOTTOM_LEFT", card.bl)\
		.replace("BOTTOM_RIGHT", card.br)\
		.replace("\n\n", "<br />")
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

const STYLES: String = """
	/* General Styles */
	body,html {
		font-family: Arial, sans-serif;
		font-size: 40px; /* Set a base font size */
		margin: 8;
		padding: 8;
		box-sizing: border-box;
		background-color: #f9f9f9;
		color: #333;
	}

	hr {
		margin: 20px 0;
	}

	p {
		margin: 8px 0;
		font-size: 1rem; /* Scales well for mobile */
	}

	/* Buttons */
	button {
		display: inline-block;
		font-size: 1.5rem;
		padding: 10px 15px;
		margin: 8px;
		background-color: #007bff;
		color: white;
		border: none;
		border-radius: 8px;
		cursor: pointer;
	}

	button:hover {
		background-color: #0056b3;
	}

	button:active {
		background-color: #00408d;
	}

	/* Form */
	form {
		margin: 10px 0;
	}

	input[type="hidden"] {
		display: none;
	}

	/* Responsive Design */
	@media (max-width: 600px) {
		body {
			font-size: 14px; /* Slightly smaller font for small devices */
		}

		button {
			font-size: 0.9rem;
			padding: 8px 12px;
		}

		p {
			font-size: 0.9rem;
		}

		hr {
			margin: 10px 0;
		}
	}
"""

const SCRIPTS: String = """
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
	<button name="action" value="play_face_down">Face Down</button>
	<button name="action" value="place_top_deck">Top Deck</button>
	<button name="action" value="place_bottom_deck">Bottom Deck</button>
	<button name="action" value="play">Play</button>
</form>
<hr />
"""
