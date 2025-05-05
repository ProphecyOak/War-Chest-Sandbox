extends Node

@export var board: BoardManager = null
var selected_coin = ""
var current_player = 1

func select_coin(coin):
	selected_coin = coin
	for rank in range(board.boardSize.y):
		for file in range(board.boardSize.x):
			var hex = board.hexes[rank][file]
			if hex == null: continue
			# TODO Check if place is owned by this player.
			if !hex.has_coin():
				hex.display_actions(["Deploy"])
				continue
			if hex.get_coin(0)["Coin"] == selected_coin:
				hex.display_actions(["Bolster"])
				continue
			hex.clear_actions()
