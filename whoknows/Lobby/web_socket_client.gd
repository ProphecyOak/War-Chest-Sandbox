extends Node

@export var client_name = "User"
@export var websocket_url = "ws://localhost:9080"
var client: WebSocketPeer = WebSocketPeer.new()
var latest_state = WebSocketPeer.STATE_CLOSED

signal socket_connected
signal data_received
signal socket_disconnected

func on_join():
	var err = client.connect_to_url(websocket_url)
	if err != OK:
		print("Unable to connect to server.")
		return

func on_close():
	client.close()

func on_send():
	client.send_text("{'response': 'Beep Boop from %s'}" % "network_id")

func poll():
	client.poll()
	var state = client.get_ready_state()
	if state != latest_state:
		latest_state = state
		$"../LobbyControls/Buttons/Peer-ID".text = "Client: %s with Status: %s" % ["network_id", latest_state]
		match latest_state:
			WebSocketPeer.STATE_OPEN:
				client.send_text("User connected.")
				emit_signal("socket_connected")
			WebSocketPeer.STATE_CLOSED:
				var code = client.get_close_code()
				emit_signal("socket_disconnected", code)
	if latest_state == WebSocketPeer.STATE_OPEN:
		while client.get_available_packet_count():
			var data = client.get_packet().get_string_from_utf8()
			emit_signal("data_received", data)
			print(data)

func _process(_delta):
	poll()
