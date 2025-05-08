extends Node

@onready var game_scene: PackedScene = preload("res://MVC Game/game.tscn")
var game: GameManager = null

func _on_web_socket_client_data_received(packet: PackedByteArray):
	var data = bytes_to_var(packet)
	match typeof(data):
		TYPE_STRING:
			print("Received String:\n%s" % data)
		TYPE_DICTIONARY:
			handle_JSON(data)
		_:
			print("Un-Supported Type: %s\n%s" % [typeof(data), data])


func handle_JSON(data):
	if "error" in data.keys() and data["error"]:
		print("Received an error with code: %s" % data["error_code"])
		return
	match data["op"]:
		"joined_room":
			print("Joined room %s" % int(data["room_id"]))
			$LobbyControls.visible = false
			game = game_scene.instantiate()
			add_child(game)
			game.web_socket = $WebSocketClient
		"image":
			var img = Image.new()
			img.load_png_from_buffer(Marshalls.base64_to_raw(data["image"]))
			var new_tex = ImageTexture.create_from_image(img)
			var new_sprite = Sprite2D.new()
			$".".add_child(new_sprite)
			new_sprite.texture = new_tex
		"game":
			game.render(data["game_state"])
