extends Node

@onready var game_scene: PackedScene = preload("res://MVC Game/game.tscn")
var game: GameManager = null
var room_host:
	set(new_value):
		room_host = new_value
		var host_guest = $RoomControls/PanelContainer/MarginContainer/VBoxContainer/Host_Guest
		host_guest.text = "You are the host of this room!\n" if room_host else "You are a guest of this room!\n"
		$RoomControls/PanelContainer/MarginContainer/VBoxContainer/BoardSettings.is_host = room_host

func _ready():
	$LobbyControls.visible = true
	$RoomControls.visible = false

func _on_web_socket_client_data_received(packet: PackedByteArray):
	var data = JSON.parse_string(packet.get_string_from_utf8())
	match typeof(data):
		TYPE_STRING:
			print("Received String:\n%s" % data)
		TYPE_DICTIONARY:
			handle_JSON(data)
		_:
			print("Un-Supported Type: %s\n%s" % [typeof(data), data])


func handle_JSON(data):
	if "error" in data.keys() and data["error"]:
		print("Received an error with code: %s\nOriginal Request:\n%s" % [data["error_code"], data["original_body"]])
		return
	if !("op" in data.keys()):
		print("Received a faulty response:\n%s" % data)
		return
	match data["op"]:
		"joined_room":
			room_host = false
			on_room_joined(data)
		"created_room":
			room_host = true
			on_room_joined(data)
		"make_host":
			room_host = true
		"image":
			var img = Image.new()
			img.load_png_from_buffer(Marshalls.base64_to_raw(data["image"]))
			var new_tex = ImageTexture.create_from_image(img)
			var new_sprite = Sprite2D.new()
			$".".add_child(new_sprite)
			new_sprite.texture = new_tex
		"game":
			game.render(data["game_state"])

func on_room_joined(data):
	$LobbyControls.visible = false
	$RoomControls.visible = true
	var room_id = $RoomControls/PanelContainer/MarginContainer/VBoxContainer/Room_ID
	room_id.text = "Room ID: %s" % data["room_id"]

func on_game_started(data):
	game = game_scene.instantiate()
	add_child(game)
	game.set_owner(self)
	game.web_socket = $WebSocketClient


func on_board_selected(board_path):
	pass # Replace with function body.
