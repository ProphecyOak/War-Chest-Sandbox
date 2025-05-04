@tool
extends Node

var hex_prefab = preload("res://hex.tscn")
@export var hex_destination: Node2D = null

@export var default_board = "eHHHHe":
	set(new_board):
		default_board = new_board
		if is_node_ready():
			generate_board()

func generate_board():
	for hex in hex_destination.get_children():
		hex_destination.remove_child(hex)
		hex.queue_free()
	var ranks = default_board.split("n")
	for rank in range(len(ranks)):
		for file in range(len(ranks[rank])):
			if ranks[rank][file] == "H": add_hex(rank,file)

func add_hex(rank, file):
	var hexCoords = Vector2(
		file * 75 * 1.1547,
		rank * 100 + 50 * (file % 2)
	)
	var new_hex = hex_prefab.instantiate()
	new_hex.position = hexCoords
	hex_destination.call_deferred("add_child", new_hex)
	new_hex.call_deferred("set_owner", hex_destination)

func _ready():
	generate_board()
