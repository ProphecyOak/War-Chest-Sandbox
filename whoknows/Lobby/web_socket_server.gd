extends Node

var server = WebSocketMultiplayerPeer.new()
var socket_status = MultiplayerPeer.ConnectionStatus.CONNECTION_DISCONNECTED
var is_socket_connected:
	get:
		return socket_status == MultiplayerPeer.ConnectionStatus.CONNECTION_CONNECTED

func on_host():
	var err = server.create_server(9080)
	if err != OK:
		print("Unable to start server.")
		return

func _process(_delta):
	server.poll()
