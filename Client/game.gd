extends Node2D

@onready var cam = $View
@onready var board = $ModularBoard
const camSpeed = 450

@onready var current_player: Node
var current_player_index = 0
var next_player_index:
	get:
		return (current_player_index + 1) % len(players)
var players = []

var game_rng = RandomNumberGenerator.new()

func _ready():
	game_rng.seed = hash(232340)
	load_game()
	for player in players:
		player.set_hand_lock(true)
	change_player(0)
	$"UI/Control/Coin Menu".initialize_list()

func _input(event):
	if event.is_action_pressed("Save"): save_game()
	if event.is_action_pressed("Center"): cam.position = Vector2(0,0)

func _process(delta):
	var movement = Vector2(0,0)
	if Input.is_action_pressed("Down"): movement.y += 1
	if Input.is_action_pressed("Up"): movement.y -= 1
	if Input.is_action_pressed("Right"): movement.x += 1
	if Input.is_action_pressed("Left"): movement.x -= 1
	cam.position = (cam.position + movement * delta * camSpeed).clamp(
		board.boundaries[0],
		board.boundaries[1]
	)

func register_player(player):
	players.append(player)
	player.player_id = len(players) - 1
	$"UI/Control/Coin Menu".register_player(player)

func change_player(new_player_index = next_player_index, unlock=true):
	current_player = players[new_player_index]
	current_player_index = new_player_index
	if unlock: current_player.set_hand_lock(false)

func end_turn(player):
	player.set_hand_lock(true)
	change_player()

func unlock_current():
	current_player.set_hand_lock(false)

func lock_all_hands():
	for player in players:
		player.set_hand_lock(true)

func save_game():
	var save_file = FileAccess.open(Global.savegame_address, FileAccess.WRITE)
	var save_nodes = get_tree().get_nodes_in_group("Persist")
	for node in save_nodes:
		# Check the node is an instanced scene so it can be instanced again during load.
		if node.scene_file_path.is_empty():
			print("persistent node '%s' is not an instanced scene, skipped" % node.name)
			continue

		# Check the node has a save function.
		if !node.has_method("save"):
			print("persistent node '%s' is missing a save() function, skipped" % node.name)
			continue

		# Call the node's save function.
		var node_data = node.call("save")

		# JSON provides a static method to serialized JSON string.
		var json_string = JSON.stringify(node_data)

		# Store the save dictionary as a new line in the save file.
		save_file.store_line(json_string)

func load_game():
	if not FileAccess.file_exists(Global.savegame_address): return
	var save_file = FileAccess.open(Global.savegame_address, FileAccess.READ)
	while save_file.get_position() < save_file.get_length():
		var json_string = save_file.get_line()
		var json = JSON.new()
		var parse_result = json.parse(json_string)
		if not parse_result == OK:
			print("JSON Parse Error: ", json.get_error_message(), " in ", json_string, " at line ", json.get_error_line())
			continue
		var node_data = json.data
		get_node(node_data["Node"]).load_from_save(node_data)
	return
