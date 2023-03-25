extends Node
class_name Networking

var is_server:bool = false
var is_client:bool = false
var is_connected:bool = false
var server: TCPServer
var server_clients: Array[Client] = []
signal data_recieved(Dictionary)
var http_client:HTTPClient = null
const DEFAULT_PORT = 8282
const DEFAULT_SERVER = "localhost"
var HEADERS = [ "User-Agent: Pirulo/1.0 (Godot)", "Accept: */*"]

class Client:
	var stream_peer: StreamPeerTCP
	var id: String

signal data_received(Dictionary)
	
func _ready() -> void:
	print_debug("networking created")

func start_server(port:int = DEFAULT_PORT):
	print_debug("hosting_game on port " + str(port) + "...")
	is_server = true
	server = TCPServer.new()
	var err = server.listen(port)
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
		server.free()
		server = null
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
#update


func _process(_delta):
	if is_server:
		server_poll()
		
	if is_client:
		client_poll()


func client_poll():
	http_client.poll()	
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


func server_poll() -> void:
	if server.is_connection_available():
		var client = Client.new()
		client.stream_peer = server.take_connection()
		client.id = uuid.v4()
		server_clients.append(client)
		client.stream_peer.set_no_delay(true)
		print("Client connected: " + client.id)
		client.stream_peer.put_data(write_server_http_message("You have Connected."))
		#client.disconnect_from_host()

	for client in server_clients:
		if client.stream_peer.get_connected_host():
			var data = client.stream_peer.get_available_bytes()
			if data > 0:
				var message = client.stream_peer.get_string(data)
				print("Received message: ", message)
				client.stream_peer.put_data(write_server_http_message("Got it!"))
				var json_data:String = JSON.parse_string(data)
				emit_signal("data_received",json_data)

	for client in server_clients:
		if client.stream_peer.get_connected_host():
			pass

func write_server_http_message(body:String) -> PackedByteArray:
	var msg = "HTTP/1.1 200 OK\r\nAccess-Control-Allow-Origin: *"
	msg += "\r\nContent-Type: application/json\r\nContent-Length:" 
	msg += str(body.to_ascii_buffer().size())
	msg += "\r\n\r\n"
	msg += body
	return msg.to_ascii_buffer()
	
		

