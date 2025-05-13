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
				root.on_leave_room(false)
				$"../Status/Button".visible = true
				$"../Status/Label".visible = false
				emit_signal("socket_disconnected")
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
	if room_id_given: send_request("join_room", {"room_id": room_id})
	else: send_request("create_room", {"room_id": "null"})
	
func send_request(op_code: String, extras: Dictionary = {}):
	extras["op"] = op_code
	client.send_text(JSON.stringify(extras))

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
	$"../LobbyControls/Buttons/JoinButton".text = "Join Room" if room_id_given else "Create Room"

func handle_incoming_data(data: Dictionary):
	if missing_keys(data, ["op"]):
		invalid_response(data, "op")
		return
	if data["op"] == "error":
		print("Received an error with code: %s\nOriginal Request:\n%s" % [data["reason"], data["request"]])
		return
	if !resolve_operation(data):
		print("Flawed or unhandled message: %s" % data)

func resolve_operation(data: Dictionary):
	match data["op"]:
		"assign_uuid":
			if missing_keys(data, ["uuid"]): return false
			print("Client assigned UUID: %s" % data["uuid"])
			UUID = data["uuid"]
		"player_joined":
			if missing_keys(data, ["name"]): return false
			print("Player `%s` joined your room." % data["name"])
		"room_created":
			if missing_keys(data, ["room_id"]): return false
			root.on_room_joined(data)
			root.room_host = true
		"joined_room":
			if missing_keys(data, ["room_id"]): return false
			root.on_room_joined(data)
		"make_host":
			root.room_host = true
		"game_settings_updated":
			send_request("pull_game_settings")
		#"image":
			#if missing_keys(data, ["image"]): return false
			#var img = Image.new()
			#img.load_png_from_buffer(Marshalls.base64_to_raw(data["image"]))
			#var new_tex = ImageTexture.create_from_image(img)
			#var new_sprite = Sprite2D.new()
			#$".".add_child(new_sprite)
			#new_sprite.texture = new_tex
		_:
			return false
	return true

func missing_keys(data: Dictionary, keys: Array[String]):
	var keys_found_missing = []
	for key in keys:
		if !data.has(key):
			keys_found_missing.append(key)
	if len(keys_found_missing) > 0:
		invalid_response(data, keys_found_missing)
	return false
	
func invalid_response(data, missing_key):
	print("Received an invalid message: %s missing the key(s): %s" % [data, missing_key])
