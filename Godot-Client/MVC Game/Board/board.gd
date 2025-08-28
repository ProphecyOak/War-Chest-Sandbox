@icon("res://Assets/Node Icons/HexGrid.svg")
extends Container
class_name BoardManager

var initialized = false
var hexes = [[]]
var board_size: Vector2i
var min_point: Vector2 = Vector2(INF, INF)
var max_point: Vector2 = Vector2(0, 0)
const hex_size = Vector2(50, 43.302)
const hex_basis = {
	"x": Vector2(hex_size.x * .75, -hex_size.y * .5),
	"y": Vector2(-hex_size.x * .75, -hex_size.y * .5)
}
const board_margin_multiplier = 2

var packed_hexagon: PackedScene = load("res://MVC Game/Board/hexagon.tscn")
@export var hex_scale: float = .95

const team_colors = [
	"b5a438", # Gold for player 1
	"436666", # Gray-Blue for player 2
	"74cd68", # Green for unclaimed
]

func delete_board():
	hexes = [[]]
	board_size = Vector2i(0,0)
	for hex in $HexHolder.get_children():
		$HexHolder.remove_child(hex)
		hex.queue_free()

func initialize_board(board_data, preview=true):
	delete_board()
	for hex in board_data["traversable_hexes"]:
		var hex_coords = Vector2i(hex[0], hex[1])
		var new_hex = packed_hexagon.instantiate()
		new_hex.scale = Vector2(hex_scale, hex_scale)
		while board_size.x <= hex_coords.x:
			for row in hexes:
				row.append(null)
			board_size.x += 1
		while board_size.y <= hex_coords.y:
			hexes.append([])
			for i in range(board_size.x):
				hexes[-1].append(null)
			board_size.y += 1
		hexes[hex_coords.y][hex_coords.x] = new_hex
		$HexHolder.add_child(new_hex)
		var rect_coords = hex_to_rec(hex_coords)
		new_hex.position = rect_coords
		min_point.x = min(min_point.x, rect_coords.x)
		min_point.y = min(min_point.y, rect_coords.y)
		max_point.x = max(max_point.x, rect_coords.x)
		max_point.y = max(max_point.y, rect_coords.y)
	var team_num = 0
	for team in board_data["control_spots"]:
		for hex in team:
			var hex_coords = Vector2i(hex[0], hex[1])
			hexes[hex_coords.x][hex_coords.y].change_color(team_colors[team_num])
		team_num += 1
		if team_num > board_data["player_count"]: team_num = -1
	if !preview: $HexHolder.scale = Vector2(2, 2)
	#TODO	IMPLEMENT SCALING BASED ON BOARD SIZE
	center_board()
	initialized = true

func hex_to_rec(hex_coords: Vector2i):
	return hex_basis["x"] * hex_coords.x + hex_basis["y"] * hex_coords.y

func center_board():
	var board_max_dim = (max_point - min_point)
	$HexHolder.position = (board_max_dim + Vector2(
		-hex_size.x * (board_margin_multiplier / 2.0 + .25),
		hex_size.y * board_margin_multiplier / 2
		)) * $HexHolder.scale.x
	custom_minimum_size = (board_max_dim + hex_size * board_margin_multiplier) * $HexHolder.scale.x

func update_board(board_data):
	if !initialized: initialize_board(board_data, false)
