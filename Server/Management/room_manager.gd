extends Node
class_name RoomManager

# RoomID and Room
var rooms: Dictionary[int, Room] = {}
# PeerID and Room
var registry: Dictionary[int, Room] = {}

@export var logger: Log = null
@export var web_socket: WebSocketServer = null

func _on_web_socket_received_message(peer_id: int, message_body: Dictionary):
	if !("op" in message_body.keys()):
		logger.add_to_log("%s: %s" % [peer_id, message_body])
		return
	var response = {
		"error": true,
		"error_code": "unknown_error",
		"original_body": message_body,
	}
	match message_body["op"]:
		"create_room":
			var new_room_id = int(web_socket.server.generate_unique_id())
			rooms[new_room_id] = Room.new(peer_id)
			registry[peer_id] = rooms[new_room_id]
			response = {
				"error": false,
				"op": "joined_room",
				"room_id": new_room_id,
			}
		"join_room":
			if !("room_id" in message_body.keys()): return
			var room_id = int(message_body["room_id"])
			if room_id in rooms.keys():
				rooms[room_id].add_peer(peer_id)
				registry[peer_id] = rooms[room_id]
				response = {
					"error": false,
					"op": "joined_room",
					"room_id": room_id,
				}
			else:
				response = {
					"error": true,
					"error_code": "room_not_found",
					"room_id": room_id
				}
	web_socket.send_JSON(response, peer_id)
