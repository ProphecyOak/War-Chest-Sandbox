class_name BoardManager
extends Node2D

@onready var buildableHexScene = preload("res://Modular-Board/buildable_hex.tscn")

var hexes = [[]]
var hex_count = 1:
	set(new_count):
		hex_count = new_count
		
var boardSize: Vector2i = Vector2i(1,1)
var grid_offset: Vector2i = Vector2i(0,0)

var small_bounds: Vector2 = Vector2(0,0)
var large_bounds: Vector2 = Vector2(0,0)
var boundaries:
	get():
		return [small_bounds, large_bounds]

func _ready():
	hexes[0].append($CenterHex)

func get_true_coords(location: Vector2i):
	return location + grid_offset

func ensure_coordinates(location: Vector2i):
	while location.y + grid_offset.y < 0:
		hexes.insert(0,[])
		for w in range(boardSize.x): hexes[0].append(null)
		boardSize.y += 1
		grid_offset.y += 1
	while location.y + grid_offset.y > boardSize.y - 1:
		hexes.append([])
		for w in range(boardSize.x): hexes[-1].append(null)
		boardSize.y += 1
	while location.x + grid_offset.x < 0:
		for h in range(boardSize.y): hexes[h].insert(0,null)
		boardSize.x += 1
		grid_offset.x += 1
	while location.x + grid_offset.x > boardSize.x - 1:
		for h in range(boardSize.y): hexes[h].append(null)
		boardSize.x += 1

func get_hex(location: Vector2i, generate=true):
	ensure_coordinates(location)
	var true_loc = get_true_coords(location)
	var found_hex = hexes[true_loc.y][true_loc.x]
	if !found_hex and generate: found_hex = new_hex(location)
	return found_hex

func new_hex(coordinates: Vector2i, type=null, hex_owner=null):
	ensure_coordinates(coordinates)
	var hex = buildableHexScene.instantiate()
	hex.coordinates = coordinates
	hex.board = self
	hex.position = location_to_rect(hex.coordinates)
	small_bounds.x = min(small_bounds.x, hex.position.x)
	small_bounds.y = min(small_bounds.y, hex.position.y)
	large_bounds.x = max(large_bounds.x, hex.position.x)
	large_bounds.y = max(large_bounds.y, hex.position.y)
	if type:
		hex.type = type
		hex.initialized = true
	if hex_owner:
		hex.controlled_by = hex_owner
	add_child(hex)
	hex.set_owner(self)
	var true_loc = get_true_coords(hex.coordinates)
	hexes[true_loc.y][true_loc.x] = hex
	hex_count += 1
	return hex

func set_edit_mode(value: bool):
	for rank in hexes:
		for hex in rank:
			if !hex: continue
			hex.toggle_editing(value)

func set_control_mode(value: bool):
	for rank in range(boardSize.y):
		for file in range(boardSize.x):
			var hex = hexes[rank][file]
			if hex == null: continue
			if value and hex.type == "Control": hex.display_actions(["Control"])
			else: hex.clear_actions()

const hex_basis = {
	"x": Vector2(BuildableHex.width * .75, -BuildableHex.height * .5),
	"y": Vector2(-BuildableHex.width * .75, -BuildableHex.height * .5)
}
func location_to_rect(location: Vector2i):
	return location.x * hex_basis["x"] + location.y * hex_basis["y"]

func get_hex_neighbors(hex: BuildableHex, generate=true) -> Array[BuildableHex]:
	var start_loc = hex.coordinates
	return [
		get_hex(start_loc + Vector2i(1, 1), generate),
		get_hex(start_loc + Vector2i(1, 0), generate),
		get_hex(start_loc + Vector2i(0, -1), generate),
		get_hex(start_loc + Vector2i(-1, -1), generate),
		get_hex(start_loc + Vector2i(-1, 0), generate),
		get_hex(start_loc + Vector2i(0, 1), generate),
	]

func setup_hex(hex: BuildableHex):
	get_hex_neighbors(hex).map(
		func (x): x.visible = x.initialized or Global.current_mode == Global.User_Mode.Board_Edit
	)

func remove_hex(hex: BuildableHex):
	var unitialized_neighbors: Array[BuildableHex] = get_hex_neighbors(hex, false).filter(
		func (x): return x != null and !x.initialized
		)
	hex.deinitialize()
	for neighbor in unitialized_neighbors:
		if len(get_hex_neighbors(neighbor, false).filter(func (x): return x != null and x.initialized)) == 0:
			kill_hex(neighbor)
	if len(get_hex_neighbors(hex, false).filter(
		func (x): return x != null and x.initialized
		)) == 0: kill_hex(hex)

func kill_hex(hex):
	if hex_count == 1: return
	var kill_coords = get_true_coords(hex.coordinates)
	hexes[kill_coords.y][kill_coords.x] = null
	remove_child(hex)
	hex.queue_free()
	hex_count -= 1
	# TODO: Modify the board and board size potentially for camera limits

func wipe_actions():
	for rank in range(boardSize.y):
		for file in range(boardSize.x):
			var hex = hexes[rank][file]
			if !hex: continue
			hex.clear_actions()

func print_hexes():
	var out = ""
	for rank in range(boardSize.y):
		for file in range(boardSize.x):
			var hex = hexes[rank][file]
			if hex is BuildableHex:
				out += "O"
			else:
				out += "-"
		out += "\n"
	print(out)
	
func save():
	var serialized_board = []
	for rank in range(boardSize.y):
		for file in range(boardSize.x):
			var hex = hexes[rank][file]
			if hex and hex.type != "": serialized_board.append({
				"x": hex.coordinates.x,
				"y": hex.coordinates.y,
				"type": hex.type,
				"owner": hex.controlled_by
			})
	return {
		"Node": get_path(),
		"Board": serialized_board,
		"Grid Offset X": grid_offset.x,
		"Grid Offset Y": grid_offset.y,
		"Board Size X": boardSize.x,
		"Board Size Y": boardSize.y,
	}

const expected_data = ["Board", "Grid Offset X", "Grid Offset Y", "Board Size X", "Board Size Y"]
func load_from_save(data: Dictionary):
	for field in expected_data: if !data.keys().has(field): return
	kill_hex($CenterHex)
	for hexData in data["Board"]:
		if hexData["type"] == "": continue
		var hex_coords = Vector2i(hexData["x"], hexData["y"])
		setup_hex(new_hex(hex_coords, hexData["type"], hexData["owner"]))
