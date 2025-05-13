extends Node

@onready var game_scene: PackedScene = preload("res://MVC Game/game.tscn")
var game: GameManager = null
var room_host = false:
	set(new_value):
		room_host = new_value
		var host_guest = $RoomControls/PanelContainer/MarginContainer/VBoxContainer/Host_Guest
		host_guest.text = "You are the host of this room!\n" if room_host else "You are a guest of this room!\n"
		$RoomControls/PanelContainer/MarginContainer/VBoxContainer/BoardSettings.is_host = room_host
		$RoomControls/PanelContainer/MarginContainer/VBoxContainer/StartGame.disabled = !room_host

var room_id:
	set(new_id):
		room_id = new_id
		var room_id_label = $RoomControls/PanelContainer/MarginContainer/VBoxContainer/HBoxContainer/Room_ID
		room_id_label.text = "Room ID: %s" % room_id
	
func room_id_to_clipboard():
	DisplayServer.clipboard_set(room_id)

func _ready():
	$LobbyControls.visible = true
	$RoomControls.visible = false

func on_room_joined(data):
	$LobbyControls.visible = false
	$RoomControls.visible = true
	room_id = data["room_id"]
	room_host = false
	# CHECK FOR BOARD_SETTING STUFF TOO!

func on_leave_room(data, choice: bool = true):
	$LobbyControls.visible = true
	$RoomControls.visible = false
	room_host = false
	if has_node("Game"): remove_child($"../Game")
	if choice: $WebSocketClient.send_request("leave_room")

func on_game_started(data):
	game = game_scene.instantiate()
	add_child(game)
	game.set_owner(self)
	game.web_socket = $WebSocketClient


func on_board_selected(board):
	$WebSocketClient.send_request("push_game_settings", {
		"board": board.get_JSON()
	})


func on_start_game():
	$WebSocketClient.send_request("start_game")
