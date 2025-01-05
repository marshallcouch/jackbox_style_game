extends Node
class_name WebServer
const SERVER_PORT = 1088
var server := TCPServer.new()
var clients: Array = []

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
	
func _handle_request(client: StreamPeerTCP, request: String):
	# HTML response with corrected diamond-shaped D-pad layout
	var client_id_loc:int = request.find("client=",request.length()-70)
	var client_id:String = "-1"
	var action:String = request.substr(request.find("action"))
	print(request)

		
	var disconnect_request = false
	if request.find("action") >0 or action.contains("%"):
		disconnect_request = action.find("disconnect") >0
	if client_id_loc > 0:
		client_id = request.substr(client_id_loc+7,32)
	if client_id != "-1" and !disconnect_request:
		client.disconnect_from_host()
		return
		print("New client connected... " + str(client_id))
	
	var body = """
<html>
	<head>
		<title>Controller</title>
		<meta name="viewport" content="width=device-width, user-scalable=no">
		"""
	body += STYLES
	body += SCRIPT.replace("CLIENT_ID", str(client_id))


	if client_id != "-1" and !disconnect_request:
		body += CONTROLLER_BODY.replace("CLIENT_ID", str(client_id))
		body = body.replace("ADDITIONAL_STYLE",PREVENT_SELECT_STYLE).replace("ADDITIONAL_SCRIPT",PREVENT_SELECT_SCRIPT)
	else:
		body += JOIN_BODY
		body = body.replace("ADDITIONAL_STYLE","").replace("ADDITIONAL_SCRIPT","")
	body += """

"""	
	# Ensure no extraneous characters before headers
	var response = set_headers(body)
	client.put_data(response.to_utf8_buffer())
	client.disconnect_from_host()

func set_headers(body:String) -> String:
	var response = "HTTP/1.1 200 OK\r\n"
	response += "Content-Type: text/html; charset=utf-8\r\n"
	response += "Content-Length: %d\r\n" % body.length()  # Correct content length
	response += "Connection: close\r\n"
	response += "\r\n"  # End of headers
	
	# Append the body content
	response += body
	return response
const SCRIPT:String = """
		<script>
			function sendAction(action) {
				var xhr = new XMLHttpRequest();
				xhr.open("POST", "/", true);
				xhr.setRequestHeader("Content-Type", "application/x-www-form-urlencoded");
				xhr.send("action=" + action + "&client=CLIENT_ID");
			}
			ADDITIONAL_SCRIPT

		</script>
	</head>
	<body>
	"""
	
const PREVENT_SELECT_SCRIPT:String = """
document.addEventListener('dblclick', function(e) {
				e.preventDefault();
			});
			
			document.addEventListener("selectionchange", () => {
				if (window.getSelection) {
					window.getSelection().removeAllRanges();
				}
			});

			document.addEventListener("contextmenu", (event) => {
				event.preventDefault();
			});
		"""
const PREVENT_SELECT_STYLE:String = """
* {
					-webkit-user-select: none; /* Safari */
					-moz-user-select: none;    /* Firefox */
					-ms-user-select: none;     /* Internet Explorer/Edge */
					user-select: none;         /* Standard */
			}
			"""
const CONTROLLER_BODY:String = """
		<div class="container">
			<div class="buttons">
				<button id="start" onclick="sendAction('start')">Start</button>
				<form method="POST">
					<button id="disconnect" name="action" value="disconnect">Disconnect</button>
					<input type="hidden" name="client" value="CLIENT_ID" />
				</form>	
			</div>
			<div class="dpad">	
				<button id="up" onclick="sendAction('up')"></button>
				<button id="down" onclick="sendAction('down')"></button>
				<button id="left" onclick="sendAction('left')"></button>
				<button id="right" onclick="sendAction('right')"></button>
				
			</div>

		</div>
	</body>
</html>"""
const JOIN_BODY:String = """
		<div class="container">
			<div class="dpad">	
				<form method="POST">
					<input id="player_name" name="player_name" type="text" placeholder="Enter Player Name" oninput="this.value = this.value.replace(/[^a-zA-Z0-9]/g, '');">
					<button id="middle" name="action" value="join">Join</button>
				</form>
			</div>
		</div>
	</body>
</html>
"""

const STYLES:String = """
		<style>
			body {
				font-family: Arial, sans-serif;
				margin: 0;
				background-color: #222;
				color: #fff;
				display: flex;
				justify-content: center;
				align-items: center;
				height: 100vh;
			}
			ADDITIONAL_STYLE


			.container {
				display: absolute;
				flex-direction: column;
				align-items: center;
				justify-content: center;
				position: relative;
				height: 620px;
				width: 300px;
			}

			.buttons {
				position: absolute;
				top: 5%; /* Places the buttons above the dpad (adjust as needed) */
				left: 50%;
				transform: translate(-50%, 0); /* Centers the buttons horizontally */
				width: 300px;
				display: flex;
				justify-content: space-between; /* Adjust alignment of buttons */
				gap: 20px;
				border-radius: 10px;
			}

			.dpad {
				position: absolute;
				top: 70%;
				left: 50%;
				transform: translate(-50%, -50%);
				width: 300px;
				height: 300px;
			}


			#up, #down, #left, #right{
				position: absolute;
				width: 100px;
				height: 100px;
				border: none;
				border-radius: 10px;
				font-size: 32px;
				cursor: pointer;
				color: #fff;
			}

			#up {
				top: 0;
				left: 50%;
				transform: translateX(-50%);
				background-color: #9b59b6;
			}

			#down {
				bottom: 0;
				left: 50%;
				transform: translateX(-50%);
				background-color: #34495e;
			}

			#left {
				left: 0;
				top: 50%;
				transform: translateY(-50%);
				background-color: #f1c40f;
			}

			#right {
				right: 0;
				top: 50%;
				transform: translateY(-50%);
				background-color: #2ecc71;
			}
			



			#middle {
				position: absolute;
				width: 150px;
				height: 70px;
				border: none;
				border-radius: 10px;
				font-size: 32px;
				cursor: pointer;
				color: #fff;
				top: 70;
				left: 50%;
				transform: translateX(-50%);
				background-color: #9b59b6;
			}




			
			#player_name {
				position: absolute;
				width: 300px;
				height: 50px;
				border: none;
				border-radius: 10px;
				font-size: 32px;
				cursor: pointer;
				color: #000;
				top: 0;
				left: 50%;
				transform: translateX(-50%);
				text-align: center;
				justify-content: center;
			}
			
			#select, #back {
				width: 100px;
				height: 100px;
				font-size: 32px;
				border: none;
				border-radius: 10px;
				cursor: pointer;
				color: #fff;
			}
			#select {
				background-color: #3498db;
			}

			#back {
				background-color: #e74c3c;
			}
			
			#start {
				position: absolute;
				top: 10px;
				right: 10px;
				width: 120px;
				height: 100px;
				font-size: 18px;
				border: none;
				border-radius: 10px;
				cursor: pointer;
				background-color: #4560ff;
				color: #fff;
			}
			
			#disconnect {
				position: absolute;
				top: 10px;
				left: 10px;
				width: 120px;
				height: 100px;
				font-size: 18px;
				border: none;
				border-radius: 10px;
				cursor: pointer;
				background-color: #e74c3c;
				color: #fff;
			}
			
			button:hover {
				opacity: 0.8;
			}

		</style>
"""
