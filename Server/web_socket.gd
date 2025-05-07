extends Node
class_name WebSocketServer

const PORT = 9080
var server = WebSocketMultiplayerPeer.new()
var socket_status = MultiplayerPeer.ConnectionStatus.CONNECTION_DISCONNECTED
var is_socket_connected:
	get:
		return socket_status == MultiplayerPeer.ConnectionStatus.CONNECTION_CONNECTED
var rooms = {}

#region Signals
signal server_starting
signal server_started
signal received_message
signal server_closed
#endregion

@export var logger: Log = null

func _ready():
	server.peer_connected.connect(on_peer_connected)
	server.peer_disconnected.connect(on_peer_disconnected)

func on_peer_connected(peer_id):
	logger.add_to_log("Client: %s connected." % peer_id)

func on_peer_disconnected(peer_id):
	logger.add_to_log("Client: %s disconnected." % peer_id)

#region Server Commands
func start_server():
	if is_socket_connected:
		logger.add_to_log("Cannot start server. Server is already running.")
		return
	var err = server.create_server(PORT)
	if err != OK:
		logger.add_to_log("Unable to start server.")
		return

func stop_server():
	if !is_socket_connected:
		logger.add_to_log("Server is not running.")
		return
	server.close()
#endregion

#region Polling
func poll():
	server.poll()
	var new_status = server.get_connection_status()
	if new_status != socket_status:
		socket_status = new_status
		match socket_status:
			MultiplayerPeer.ConnectionStatus.CONNECTION_CONNECTING:
				logger.add_to_log("Server starting...")
				emit_signal("server_starting")
			MultiplayerPeer.ConnectionStatus.CONNECTION_CONNECTED:
				logger.add_to_log("Server started on port: %s." % PORT)
				emit_signal("server_started")
			MultiplayerPeer.ConnectionStatus.CONNECTION_DISCONNECTED:
				logger.add_to_log("Server on port: %s closed." % PORT)
				emit_signal("server_closed")
	if !is_socket_connected: return
	while server.get_available_packet_count():
		var packet = server.get_packet()
		var message_body = JSON.parse_string(packet.get_string_from_utf8())
		emit_signal("received_message", message_body)

func _process(_delta):
	poll()
#endregion
