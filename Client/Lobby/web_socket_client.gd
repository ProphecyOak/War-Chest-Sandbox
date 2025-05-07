extends Node

@export var client_name = "User"
@export var websocket_url = "ws://localhost:9080"
var client: WebSocketPeer = WebSocketPeer.new()
var latest_state = WebSocketPeer.STATE_CLOSED
var room = null

signal socket_connected
signal data_received
signal socket_disconnected

func on_join():
	if latest_state != WebSocketPeer.STATE_CLOSED: return
	room = $"../LobbyControls/Buttons/RoomCode".text
	var err = client.connect_to_url(websocket_url)
	if err != OK:
		print("Unable to connect to server.")
		return

func on_close():
	client.close()

func on_send(message = null):
	if latest_state != WebSocketPeer.STATE_OPEN: return
	if !message:
		print("Client sending test message")
		client.send_text('{"body":"Test Message"}')
		return

func poll():
	client.poll()
	var state = client.get_ready_state()
	if state != latest_state:
		latest_state = state
		match latest_state:
			WebSocketPeer.STATE_OPEN:
				emit_signal("socket_connected")
				var connectionMessage = {
					"op": "join_room" if room else "create_room",
					"room_code": room if room else "null"
				}
				client.send_text(JSON.stringify(connectionMessage))
			WebSocketPeer.STATE_CLOSED:
				var code = client.get_close_code()
				emit_signal("socket_disconnected", code)
	if latest_state == WebSocketPeer.STATE_OPEN:
		while client.get_available_packet_count():
			var packet = client.get_packet()
			if client.was_string_packet():
				var data = packet.get_string_from_utf8()
				emit_signal("data_received", data)
				print("Client: %s" % data)
			else: print("Client: %s" % packet)

func _process(_delta):
	poll()
