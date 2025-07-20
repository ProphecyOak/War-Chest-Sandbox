extends Node
class_name RoomManager

# RoomID and Room
var rooms: Dictionary[int, Room] = {}
# PeerID and Room
var registry: Dictionary[int, Room] = {}

@export var logger: Log = null
@export var web_socket: WebSocketServer = null

func peer_disconnected_from_room(peer_id: int):
	if !(peer_id in registry.keys()): return
	var old_room = registry[peer_id]
	old_room.remove_peer(peer_id)
	registry.erase(peer_id)
	match len(old_room.connected_peers):
		0:
			rooms.erase(old_room.room_id)
		1:
			web_socket.send(normal_response("make_host"),old_room.connected_peers[0])
	logger.add_to_log("%s disconnected from room: %s\n\t%s peers in room" % [peer_id, old_room.room_id, len(old_room.connected_peers)])

#region Response Generators
func error_response(error_code: String, message, extras={}):
	extras["error"] = true
	extras["error_code"] = error_code
	extras["original_body"] = message
	return extras
	
func normal_response(op_code: String, extras={}):
	extras["error"] = false
	extras["op"] = op_code
	return extras
#endregion

func _on_web_socket_received_message(peer_id: int, message_body: Dictionary):
	if !("op" in message_body.keys()):
		logger.add_to_log("%s: %s" % [peer_id, message_body])
		return
	var response = error_response("unknown_error", message_body)
	match message_body["op"]:
		"create_room":
			var new_room_id = int(web_socket.server.generate_unique_id())
			rooms[new_room_id] = Room.new(new_room_id, web_socket, peer_id)
			registry[peer_id] = rooms[new_room_id]
			logger.add_to_log("%s hosted room: %s" % [peer_id, new_room_id])
			response = normal_response("created_room",{"room_id": new_room_id})
		"join_room":
			if !("room_id" in message_body.keys()):
				return
			var room_id = int(message_body["room_id"])
			if room_id in rooms.keys():
				logger.add_to_log("%s joined room: %s" % [peer_id, room_id])
				rooms[room_id].add_peer(peer_id)
				registry[peer_id] = rooms[room_id]
				response = normal_response("joined_room",{"room_id": room_id})
			else:
				response = error_response("room_not_found", message_body, {"room_id": room_id})
		"leave_room":
			peer_disconnected_from_room(peer_id)
	web_socket.send(response, peer_id)
	#registry[peer_id].send_game(peer_id)
