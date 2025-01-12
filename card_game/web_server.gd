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
	#print("server running..." + Time.get_datetime_string_from_system())
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
		if c.is_queued_for_deletion():
			continue
		cards.append(c)
	return cards
func get_card_count() -> int:
	return player_hand.get_child_count()

func _handle_request(client: StreamPeerTCP, request: String):
	var request_lines = request.split("\n")
	if request_lines.size() == 0:
		return
	var request_line = request_lines[0]  # First line of the HTTP request
	var path = request_line.split(" ")[1]  # Extract the path (e.g., "/icon.png")

	if path == "/icon.png":
		# Serve the image
		_send_image(client, "res://icon.png")
	else:
		# Serve the HTML
		var body = SKELETON.replace("STYLE_CONTENT", STYLES)\
			.replace("SCRIPT_CONTENT", SCRIPTS)\
			.replace("BODY_CONTENT", _cards_in_hand())
		var response = set_headers(body)
		client.put_data(response.to_utf8_buffer())

	client.disconnect_from_host()

func _handle_action(params:String):
	var param_split = params.split("&")
	var action:String = param_split[0].split("=")[1]
	var card_name:String = param_split[1].split("=")[1].replace("+"," ")
	for card in get_cards():
		if card.tl == card_name:
			if action == "play_face_down":
				card.play_card_face_down()
			elif action == "play":
				card.play_card()
			elif action == "place_top_deck":
				card.place_card_back_in_deck.emit(card.card, "top")
				card.queue_free()
			elif action == "place_bottom_deck":
				card.place_card_back_in_deck.emit(card.card, "bottom")
				card.queue_free()
			return
	

func _send_image(client: StreamPeerTCP, image_path: String):
	# Load the image from the file system
	var image = Image.new()
	var error = image.load(image_path)
	if error != OK:
		print("Failed to load image: ", image_path)
		return

	# Convert the image to PNG format (binary data)
	var image_data
	if image_path.contains("jpg") or image_path.contains("jpeg"):
		image_data = image.save_jpg_to_buffer()
	elif image_path.contains("png"):
		image_data = image.save_png_to_buffer()
	elif image_path.contains("webp"):
		image_data = image.save_webp_to_buffer()
	# Prepare HTTP headers
	var response = "HTTP/1.1 200 OK\r\n"
	response += "Content-Type: image/png\r\n"  # Change to "image/jpeg" if using JPEG
	response += "Content-Length: %d\r\n" % image_data.size()
	response += "Connection: close\r\n"
	response += "\r\n"  # End of headers

	# Send headers and image data
	client.put_data(response.to_utf8_buffer())
	client.put_data(image_data)
	


func _cards_in_hand() -> String:
	var cards:Array[Card] = get_cards()
	var cards_body:String = "<p>Count: " + str(cards.size()) + "</p> <form method=\"POST\"><button name=\"REFRESH\" value=\"refresh\">refresh</button></form>"
	for card in cards:
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
		<img src="icon.png"/>
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
	<button name="ACTION" value="play_face_down">Face Down</button>
	<button name="ACTION" value="place_top_deck">Top Deck</button>
	<button name="ACTION" value="place_bottom_deck">Bottom Deck</button>
	<button name="ACTION" value="play">Play</button>
	<input name="card_name" type="hidden" value="TOP_LEFT">
</form>
<hr />
"""
