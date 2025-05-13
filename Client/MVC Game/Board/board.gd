@icon("res://Assets/Node Icons/HexGrid.svg")
extends Node2D

var hexes = [[]]
var board_size: Vector2i
const hex_size = Vector2(50, 43.302)
const hex_basis = {
	"x": Vector2(hex_size.x * .75, -hex_size.y * .5),
	"y": Vector2(-hex_size.x * .75, -hex_size.y * .5)
}
var packed_hexagon: PackedScene = load("res://MVC Game/Board/hexagon.tscn")

var team_colors = [
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

func initialize_board(board_data):
	print("Creating Board")
	delete_board()
	for hex in board_data["traversable_hexes"]:
		var hex_coords = Vector2i(hex[0], hex[1])
		var new_hex = packed_hexagon.instantiate()
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
		new_hex.position = hex_basis["x"] * hex_coords.x + hex_basis["y"] * hex_coords.y
	var team_num = 0
	for team in board_data["control_spots"]:
		for hex in team:
			var hex_coords = Vector2i(hex[0], hex[1])
			hexes[hex_coords.x][hex_coords.y].change_color(team_colors[team_num])
		team_num += 1
		if team_num > board_data["player_count"]: team_num = -1

func update_board(data):
	pass
