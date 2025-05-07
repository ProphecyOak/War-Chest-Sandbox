extends Node
class_name RoomManager

@export var logger: Log = null
var rooms: Dictionary[int, Room] = {}


func _on_web_socket_received_message(message_body: Dictionary):
	if !message_body["op"]: return
	match message_body["op"]:
		"create_room":
			pass
		"join_room":
			pass
