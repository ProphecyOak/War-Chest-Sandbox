extends Control
class_name GameManager

var web_socket: WebSocketClient = null

#region saving/loading
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
#endregion


func print_relevant_state(data, irrelevant_keys = []):
	var cloned_data = data.duplicate()
	if cloned_data is Dictionary:
		for key in irrelevant_keys:
			cloned_data[key] = null
	print(JSON.stringify(data,"  "))

func _ready():
	load_game()

func render(game_data):
	$Board.update_board(game_data["board"])
	for player in game_data["players"]:
		for coin in player["units"]:
			place_coin(coin)

func place_coin(coin: Dictionary):
	match coin["state"]:
		"In_Hand":
			pass
		_:
			print("Unhandled coin state: %s" % coin["state"])
