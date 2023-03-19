extends Node
class_name HTTPServer

signal client_connected(id:int)
signal client_disconnected(id:int)
signal message_received(id:int, msg:String)


var server: TCPServer
var clients: Array[StreamPeerTCP] = []

func _ready() -> void:
	server = TCPServer.new()

func listen(port:int) -> Error:
	return server.listen(port)

func _process(delta: float) -> void:
	if server.is_connection_available():
		var client = server.take_connection()
		clients.append(client)
		client.set_no_delay(true)
		print("Client connected: ")

	for client in clients:
		if client.get_connected_host():
			var data = client.get_available_bytes()
			if data > 0:
				var message = client.get_string(data)
				print("Received message: ", message)
		else:
			clients.erase(clients.find(client))

	for client in clients:
		if client.get_connected_host():
			var response= "HTTP/1.1 200 OK\r\nContent-Type: text/html\r\n\r\nHello, world!"
			client.put_data(response.to_ascii_buffer())
			client.disconnect_from_host()

