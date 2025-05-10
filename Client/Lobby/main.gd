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
