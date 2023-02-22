extends Node
class_name Networking

var is_server:bool = false
var is_client:bool = false
var is_connected:bool = false
var peer = null
var player_list:Array = []

func _ready() -> void:
	print_debug("networking started")



func start_game(port:int = 8080):
	is_server = true
	peer = WebSocketServer.new()
	peer.listen(port, ['custom'], true)
	peer.connect("server_disconnected", self, "disconnect_game")
	peer.connect("network_peer_disconnected", self, "_peer_disconnected")
	peer.connect("network_peer_connected", self, "_peer_connected")


func join_game(server:String = 'localhost', port:int = 8080):
	peer = WebSocketClient.new()
	peer.connect_to_url("ws://" + server + ":" + str(port),['custom'], true)
	peer.connect("connection_failed", self, "disconnect_game")
	peer.connect("connected_to_server", self, "_peer_connected")
	is_client = true


func stop_game():
	is_server = false
	disconnect_game()
	

func disconnect_game():
	if peer.is_connected("server_disconnected", self, "disconnect_game"):
		peer.disconnect("server_disconnected", self, "disconnect_game")
	if peer.is_connected("connection_failed", self, "disconnect_game"):
		peer.disconnect("connection_failed", self, "disconnect_game")
	if peer.is_connected("connected_to_server", self, "_peer_connected"):
		peer.disconnect("connected_to_server", self, "_peer_connected")



func _peer_connected(id):
	print_debug("connected")
	player_list.append({"player_id":id,"player_name":"default"})


func _peer_disconnected(id):
	print_debug("peer disconnected")
	for i in player_list.size():
		if id == player_list[i]["player_id"]:
			player_list.remove(i)
	

func send_packet(packet_content:String,peer_id:int) -> void:
	if is_client:
		peer.send_packet(packet_content.to_utf8())
	if is_server:
		peer.send_packet(packet_content.to_utf8())
	
	
func _process(_delta):
	if peer:
		peer.poll()
