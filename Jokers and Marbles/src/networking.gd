extends Node
class_name Networking

var is_server:bool = false
var is_client:bool = false
var is_connected:bool = false
var http_server:HTTPServer = null
var http_client:HTTPClient = null
const DEFAULT_PORT = 8282
const DEFAULT_SERVER = "localhost"
var HEADERS = [ "User-Agent: Pirulo/1.0 (Godot)", "Accept: */*"]

var WaitBetweenHTTP: Timer = Timer.new()



	
func _ready() -> void:
	print_debug("networking created")
	self.add_child(WaitBetweenHTTP)
	WaitBetweenHTTP.one_shot = true

func start_server(port:int = DEFAULT_PORT):
	print_debug("hosting_game on port " + str(port) + "...")
	is_server = true
	http_server = HTTPServer.new()
	var err = http_server.listen(port)
	if err != OK:
		print_debug("error starting server " + str(err))


func join_game(server:String = DEFAULT_SERVER, port:int = DEFAULT_PORT):
	var url = server + ":" + str(port)
	is_client = true
	http_client = HTTPClient.new()
	var err = http_client.connect_to_host(server, port)
	assert(err == OK)


func stop_game():
	if is_client:
		http_client.free()
		http_client = null
		is_client = false
	
	if is_server:
		http_server.free()
		http_server = null
		is_server = false

func get_time()-> String:
	var t = Time.get_datetime_dict_from_system()
	var mt = Time.get_ticks_msec()
	return str(t["hour"]) +":" + str(t["minute"]) +":"+ \
	str(t["second"]) + " - " + str(mt) + " - "


#server has a peer disconnected
func _peer_disconnected(id):
	print_debug( get_time() + "peer disconnected: " + str(id))


func send_packet(packet_content:String,peer_id:int = 1) -> void:
	if is_client:
		pass
	if is_server:
		pass


func _process(_delta):
	if is_server:
		http_server.poll()
		
	if is_client:
		client_poll()
		
func client_poll():
	http_client.poll()
	print(str(http_client.get_status()))
	if WaitBetweenHTTP.is_stopped() and \
		http_client.get_status() == HTTPClient.STATUS_CONNECTED:
		# Request a page from the site (this one was chunked..)
		var err = http_client.request(HTTPClient.METHOD_POST, "/", HEADERS) 
		assert(err == OK) # Make sure all is OK.
		WaitBetweenHTTP.start(.25)
		
	if http_client.has_response():
		# If there is a response...
		var headers = http_client.get_response_headers() # Get response headers.
		print("headers: ", headers)
		print("code: ", http_client.get_response_code()) # Show response code.
		# Getting the HTTP Body
		if !http_client.is_response_chunked():
			# Or just plain Content-Length
			var bl = http_client.get_response_body_length()

		# This method works for both anyway
		var rb = PackedByteArray() # Array that will hold the data.
		if http_client.get_status() == HTTPClient.STATUS_BODY:
			var chunk = http_client.read_response_body_chunk()
			if chunk.size() == 0:
				if not OS.has_feature("web"):
					OS.delay_usec(20)
				else:
					await(Engine.get_main_loop())
			else:
				rb = rb + chunk # Append to read buffer.

		print("bytes got: ", rb.size())
		var text = rb.get_string_from_ascii()
		print("Text: ", text)
		
	

class HTTPServer:
	var server: TCPServer
	var clients: Array[StreamPeerTCP] = []

	func listen(port:int) -> Error:
		server = TCPServer.new()
		var err = server.listen(port)
		return err

	func poll() -> void:
		if server.is_connection_available():
			var client = server.take_connection()
			clients.append(client)
			client.set_no_delay(true)
			print("Client connected: ")
			client.put_data(write_http_message("You have Connected."))
			#client.disconnect_from_host()

		for client in clients:
			if client.get_connected_host():
				var data = client.get_available_bytes()
				if data > 0:
					var message = client.get_string(data)
					print("Received message: ", message)
					client.put_data(write_http_message("Got it!"))

		for client in clients:
			if client.get_connected_host():
				pass

	func write_http_message(body:String) -> PackedByteArray:
		var msg = "HTTP/1.1 200 OK\r\nAccess-Control-Allow-Origin: *"
		msg += "\r\nContent-Type: application/json\r\nContent-Length:" 
		msg += str(body.to_ascii_buffer().size())
		msg += "\r\n\r\n"
		msg += body
		return msg.to_ascii_buffer()
		
		

