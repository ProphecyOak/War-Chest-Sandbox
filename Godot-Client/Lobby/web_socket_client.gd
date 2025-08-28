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
	$"../Outside-Of-Game/LobbyControls/Buttons/JoinButton".text = "Join Room" if room_id_given else "Create Room"

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
	var game
	if root.has_node("Game"): game = $"../Game"
	else: game = null
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
			for x in load_units():
				send_request("push_image", x)
		"joined_room":
			if missing_keys(data, ["room_id"]): return false
			root.on_room_joined(data)
		"make_host":
			root.room_host = true
		"game_settings_updated":
			send_request("pull_game_settings")
		"supply_game_settings":
			if missing_keys(data, ["game_state"]): return false
			if "board" in data["game_state"].keys():
				$"..".board_preview.visible = true
				$"..".board_preview.get_node("./MarginContainer/VBoxContainer/BoardPreview").initialize_board(data["game_state"]["board"])
		"game_started":
			if missing_keys(data, ["game_state"]): return false
			root.on_game_started()
			$"../Game".render(data["game_state"])
		"game_state":
			if missing_keys(data, ["game_state"]): return false
			if game == null: return false;
			game.render(data["game_state"])
		"obligation":
			print("%s: %s" % [UUID, data])
			send_request("obligation_response", {"answer":{
				"obligation_type":data["obligation_type"]
				}})
		"image_list":
			if missing_keys(data, ["images"]): return false
			for image_id in data["images"]["units"].keys():
				var img = decode_image(data["images"]["units"][image_id])
				Global.additional_icons["units"][image_id] = ImageTexture.create_from_image(img)
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

func load_units():
	#TODO Need to eventually allow for mod selection to selectively send images
	#     instead of everything the host has to offer all at once.
	var unit_images = []
	var unit_dir = DirAccess.open("res://UserResources/Units")
	for unit_name in unit_dir.get_directories():
		if !unit_dir.file_exists("%s/coin.png" % unit_name): continue
		var image_path = "res://UserResources/Units/%s/coin.png" % unit_name
		unit_images.append({
			"image_id": unit_name.to_lower(),
			"image_string": encode_image(image_path)
		})
		var new_unit_texture = ImageTexture.create_from_image(load(image_path).get_image())
		Global.additional_icons["units"][unit_name.to_lower()] = new_unit_texture
	return unit_images

func encode_image(filepath: String):
	return Marshalls.raw_to_base64(load(filepath).get_image().save_png_to_buffer())

func decode_image(encoded: String):
	var img = Image.new()
	img.load_png_from_buffer(Marshalls.base64_to_raw(encoded))
	return img
