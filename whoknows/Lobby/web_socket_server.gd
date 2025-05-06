extends Node

const PORT = 9080
var server = WebSocketMultiplayerPeer.new()
var socket_status = MultiplayerPeer.ConnectionStatus.CONNECTION_DISCONNECTED
var is_socket_connected:
	get:
		return socket_status == MultiplayerPeer.ConnectionStatus.CONNECTION_CONNECTED

func _ready():
	server.peer_connected.connect(on_peer_connected)
	server.peer_disconnected.connect(on_peer_disconnected)

func on_peer_connected(peer_id):
	print("Client: %s connected" % peer_id)
func on_peer_disconnected(peer_id):
	print("Client: %s disconnected" % peer_id)

func on_host():
	var err = server.create_server(PORT)
	if err != OK:
		print("Unable to start server.")
		return

func poll():
	server.poll()
	var new_status = server.get_connection_status()
	if new_status != socket_status:
		socket_status = new_status
		match socket_status:
			MultiplayerPeer.ConnectionStatus.CONNECTION_CONNECTING:
				print("Server starting...")
			MultiplayerPeer.ConnectionStatus.CONNECTION_CONNECTED:
				print("Server started on port: %s" % PORT)
			MultiplayerPeer.ConnectionStatus.CONNECTION_DISCONNECTED:
				print("Server on port: %s closed." % PORT)
	if !is_socket_connected: return
	while server.get_available_packet_count():
		var packet = server.get_packet()
		var message_body = JSON.parse_string(packet.get_string_from_utf8())
		print(message_body)

func _process(_delta):
	poll()
