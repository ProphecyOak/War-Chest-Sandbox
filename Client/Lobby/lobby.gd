extends Node

@onready var game_scene: PackedScene = preload("res://MVC Game/game.tscn")
var game: Node2D = null

func _on_web_socket_client_data_received(data):
	match typeof(data):
		TYPE_STRING:
			pass
		Image:
			pass
		TYPE_DICTIONARY:
			handle_JSON(data)
		_:
			print(data)


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
