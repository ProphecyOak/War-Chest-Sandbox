class_name Room

var room_id: int
var connected_peers: Array[int] = []

func add_peer(peer_id: int):
	connected_peers.append(peer_id)
