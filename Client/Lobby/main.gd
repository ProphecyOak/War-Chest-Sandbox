extends Node

var game: GameManager = null
@onready var game_scene: PackedScene = preload("res://MVC Game/game.tscn")

@export var host_indicator: Label
@export var room_id_label: Label
@export var board_preview: PanelContainer
@export var start_game_button: Button
@export var board_settings_manager: VBoxContainer

var room_host = false:
	set(new_value):
		room_host = new_value
		var host_guest = host_indicator
		host_guest.text = "You are the host of this room!\n" if room_host else "You are a guest of this room!\n"
		board_settings_manager.is_host = room_host
		start_game_button.disabled = !room_host

var room_id:
	set(new_id):
		room_id = new_id
		var room_id_label = room_id_label
		room_id_label.text = "Room ID: %s" % room_id
		
var in_game:
	set(new_value):
		in_game = new_value
		if in_game:
			for component in $"Outside-Of-Game".get_children():
				component.visible = false
			if has_node("Game"): $Game.visible = false
	
func room_id_to_clipboard():
	DisplayServer.clipboard_set(room_id)

func _ready():
	$"Outside-Of-Game/LobbyControls".visible = true
	$"Outside-Of-Game/RoomControls".visible = false

func on_room_joined(data):
	$WebSocketClient.send_request("pull_game_settings")
	board_preview.visible = false
	$"Outside-Of-Game/LobbyControls".visible = false
	$"Outside-Of-Game/RoomControls".visible = true
	room_id = data["room_id"]
	room_host = false

func on_leave_room(data, choice: bool = true):
	in_game = false
	$"Outside-Of-Game/LobbyControls".visible = true
	$"Outside-Of-Game/RoomControls".visible = false
	room_host = false
	if has_node("Game"): remove_child($"../Game")
	if choice: $WebSocketClient.send_request("leave_room")

func on_game_started():
	in_game = true
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
