class_name Room

var room_id: int
var connected_peers: Array[int] = []
var web_socket: WebSocketServer = null
var game: Game = null
var room_actions = UndoRedo.new()

func add_peer(peer_id: int):
	connected_peers.append(peer_id)

func _init(web_socket_: WebSocketServer, peer_id: int):
	web_socket = web_socket_
	game = Game.new()
	add_peer(peer_id)

func move_unit():
	pass

func send_game(peer_id = null):
	var response = {
		"op": "game",
		"game_state": game.get_JSON()
	}
	if peer_id:
		web_socket.send(response, peer_id)
		return
	for each_id in connected_peers:
		web_socket.send(response, each_id)

class Game:
	var turn_order: Array[int] = []
	var active_player_id: int
	var turn: int = 0
	var winning_score: int = 6
	var initiative_taken: int = -1
	var players: Array[Player] = []
	var forts: Array[Vector2i] = []
	var teams: Array[Team] = []
	var board: Board = load("res://Resources/Boards/Default.tres")
	func get_JSON():
		return {
			"active_player_id": active_player_id,
			"players": players.map(func (x): return x.get_JSON()),
			"turn": turn,
			"winning_score": winning_score,
			"forts": forts,
			"teams": teams.map(func (x): return x.get_JSON()),
			"board": board.get_JSON(),
		}

class Player:
	var id: int
	var army: Array[String] = []
	var team_id: int
	var has_initiative
	var units: Array[Unit] = []
	func get_JSON():
		return {
			"id": id,
			"team_id": team_id,
			"has_initiative": has_initiative,
			"units": units.map(func (x): return x.get_JSON()),
		}

class Team:
	var id: int
	var color: Color = Color("b5a438")
	var controlled_spaces: Array[Vector2i] = []
	func get_JSON():
		return {
			"id": id,
			"color": str(color),
			"controlled_spaces": controlled_spaces.map(func (x): return [x.x, x.y]),
		}
