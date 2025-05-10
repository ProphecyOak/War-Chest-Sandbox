extends Node
class_name WebSocketClient

@export var client_name = "User"
@export var websocket_url = "ws://localhost:9080"

@onready var root = $".."

var UUID = null
var client: WebSocketPeer = WebSocketPeer.new()
var socket_status = WebSocketPeer.STATE_CLOSED:
	set(new_status):
		socket_status = new_status
		match socket_status:
			WebSocketPeer.STATE_OPEN:
				$"../Status/Button".visible = false
				$"../Status/Label".visible = true
				emit_signal("socket_connected")
			WebSocketPeer.STATE_CLOSED:
				$"../Status/Button".visible = true
				$"../Status/Label".visible = false
				emit_signal("socket_disconnected")
				on_leave(false)
var room_id = null
var room_id_given: bool:
	get:
		return room_id and len(room_id) > 0

signal socket_connected
signal socket_disconnected

func connect_to_server():
	if socket_status != WebSocketPeer.STATE_CLOSED: return
	if UUID:
		client.set_handshake_headers(["uuid: %s" % UUID])
	else:
		client.set_handshake_headers(["uuid: null"])
	var err = client.connect_to_url(websocket_url)
	if err != OK:
		print("Unable to connect to server.")
		return

func on_join():
	if socket_status != WebSocketPeer.STATE_OPEN: return
	var connectionMessage = {
		"op": "join_room" if room_id_given else "create_room",
		"room_id": room_id if room_id_given else "null"
	}
	send_JSON(connectionMessage)

func on_leave(send: bool = true):
	$"../LobbyControls".visible = true
	$"../RoomControls".visible = false
	if root.has_node("Game"):
		root.remove_child($"../Game")
	if send: send_JSON({
		"op": "leave_room",
	})

func send_JSON(message):
	client.send_text(JSON.stringify(message))

func poll():
	client.poll()
	var state = client.get_ready_state()
	if state != socket_status:
		socket_status = state
	if socket_status == WebSocketPeer.STATE_OPEN:
		while client.get_available_packet_count():
			var packet = client.get_packet()
			var data = JSON.parse_string(packet.get_string_from_utf8())
			if typeof(data) != TYPE_DICTIONARY:
				print("Un-Supported Type: %s\n%s" % [typeof(data), data])
			handle_incoming_data(data)

func _process(_delta):
	poll()

func _on_room_code_text_changed(new_text):
	room_id = new_text
	$"../rootControls/Buttons/JoinButton".text = "Join Room" if room_id_given else "Create Room"

func handle_incoming_data(data: Dictionary):
	if "error" in data.keys() and data["error"]:
		invalid_response(data, "error_code")
		print("Received an error with code: %s\nOriginal Request:\n%s" % [data["error_code"], data["request"]])
		return
	if missing_keys(data, ["op"]): return
	resolve_operation(data)

func resolve_operation(data: Dictionary):
	match data["op"]:
		"assign_uuid":
			if missing_keys(data, ["uuid"]): return
			print("Client assigned UUID: %s" % data["uuid"])
			UUID = data["uuid"]
		#"image":
			#if missing_keys(data, ["image"]): return
			#var img = Image.new()
			#img.load_png_from_buffer(Marshalls.base64_to_raw(data["image"]))
			#var new_tex = ImageTexture.create_from_image(img)
			#var new_sprite = Sprite2D.new()
			#$".".add_child(new_sprite)
			#new_sprite.texture = new_tex

func missing_keys(data: Dictionary, keys: Array[String]):
	for key in keys:
		if !data.has(key):
			invalid_response(data, key)
			return true
	return false
	
func invalid_response(data, missing_key):
	print("Received an invalid request: %s missing the key: %s" % [data, missing_key])
