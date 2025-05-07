class_name Room

var room_id: int
var connected_peers: Array[int] = []

var room_actions = UndoRedo.new()

func add_peer(peer_id: int):
	connected_peers.append(peer_id)

func _init(peer_id: int):
	add_peer(peer_id)

func move_unit():
	pass

class Game:
	var turn_order: Array[int] = []
	var active_player_id: int
	var turn: int = 0
	var winning_score: int = 6
	var initiative_taken: int = -1
	var players: Dictionary[int, Player] = {}
	var control_spots: Array[ControlSpot] = []
	var teams: Array[Team] = []

class Player:
	var id: int
	var army: Array[String] = []
	var team_id: int
	var has_initiative
	var units: Array[Unit] = []

class Team:
	var id: int
	var color: Color = Color("b5a438")

class ControlSpot:
	var location: Vector2i
	var has_fort: bool = false
	var controlling_team_id: int = -1
