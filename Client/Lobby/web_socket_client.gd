extends Node
class_name WebSocketClient

@export var client_name = "User"
@export var websocket_url = "ws://localhost:9080"
var client: WebSocketMultiplayerPeer = WebSocketMultiplayerPeer.new()
var socket_status = WebSocketMultiplayerPeer.ConnectionStatus.CONNECTION_DISCONNECTED
var room_id = null
var room_id_given: bool:
	get:
		return room_id and len(room_id) > 0

signal socket_connected
signal data_received
signal socket_disconnected

func on_join():
	if socket_status != WebSocketMultiplayerPeer.ConnectionStatus.CONNECTION_DISCONNECTED: return
	var err = client.create_client(websocket_url)
	if err != OK:
		print("Unable to connect to server.")
		return

func on_close():
	client.close()

func send_JSON(message):
	client.get_peer(1).send_text(JSON.stringify(message))

func poll():
	client.poll()
	var state = client.get_connection_status()
	if state != socket_status:
		socket_status = state
		match socket_status:
			WebSocketMultiplayerPeer.ConnectionStatus.CONNECTION_CONNECTED:
				emit_signal("socket_connected")
				var connectionMessage = {
					"op": "join_room" if room_id_given else "create_room",
					"room_id": room_id if room_id_given else "null"
				}
				send_JSON(connectionMessage)
			WebSocketMultiplayerPeer.ConnectionStatus.CONNECTION_DISCONNECTED:
				emit_signal("socket_disconnected")
	if socket_status == WebSocketMultiplayerPeer.ConnectionStatus.CONNECTION_CONNECTED:
		while client.get_available_packet_count():
			var data = client.get_var()
			emit_signal("data_received", data)

func _process(_delta):
	poll()


func _on_room_code_text_changed(new_text):
	room_id = new_text
	$"../LobbyControls/Buttons/JoinButton".text = "Join Room" if room_id_given else "Create Room"
