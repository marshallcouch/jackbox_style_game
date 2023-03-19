extends Node
class_name Networking

var is_server:bool = false
var is_client:bool = false
var is_connected:bool = false
var http_server:HTTPServer = null
var peer:HTTPClient = null
var player_list:Array = []
const DEFAULT_PORT = 8282
const DEFAULT_SERVER = "localhost"
var HEADERS = [ "User-Agent: Pirulo/1.0 (Godot)", "Accept: */*"]

func _ready() -> void:
	print_debug("networking created")

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
	peer = HTTPClient.new()
	var err = peer.connect_to_host(server, port)
	if err != OK:
		print_debug("Unable to connect " + str(err))
	else:
		print_debug("connecting...")
		#peer.send()
	OS.delay_msec(500)
	peer.poll()
	#peer.request(HTTPClient.METHOD_POST,"/index",HEADERS,"")
	OS.delay_msec(500)
	var hr = peer.has_response()
	var bl = peer.get_response_body_length()
	var code = peer.get_response_code()
	var h = peer.get_response_headers_as_dictionary()
	var rc = peer.is_response_chunked()
	var response = peer.read_response_body_chunk()
	
	var req = HTTPRequest.new()

	

	


func stop_game():
	if is_client:
		peer.free()
		peer = null
		is_client = false
	
	if is_server:
		http_server.free()
		http_server = null
		is_server = false

func get_time()-> String:
	var t = Time.get_datetime_dict_from_system()
	var mt = Time.get_ticks_msec()
	return str(t["hour"]) +":" + str(t["minute"]) +":"+ str(t["second"]) + " - " + str(mt) + " - "
	
	
#server has a peer disconnected
func _peer_disconnected(id):
	print_debug( get_time() + "peer disconnected: " + str(id))
	for i in player_list.size():
		if id == player_list[i]["player_id"]:
			player_list.pop_at(i)

func broadcast(broadcast_content:String) -> void:
	pass

func send_packet(packet_content:String,peer_id:int = 1) -> void:
	if is_client:
		pass
	if is_server:
		pass


func _process(_delta):
	if is_server:
		http_server.poll()
		
	if is_client:
		peer.poll()
		var status = peer.get_ready_state()
			


func _on_data(id:int = 0) -> void:
	var pkt = peer.get_peer(id).get_packet().get_string_from_utf8()
	print_debug("Got data from client %d: %s " % [id, pkt])
	
	



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
			var response= "HTTP/1.1 200 OK\r\nContent-Type: text/html\r\n\r\nHello, world!"
			client.put_data(response.to_ascii_buffer())

		for client in clients:
			if client.get_connected_host():
				var data = client.get_available_bytes()
				if data > 0:
					var message = client.get_string(data)
					print("Received message: ", message)

		for client in clients:
			if client.get_connected_host():
				pass


