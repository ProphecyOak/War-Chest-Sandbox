extends Node

@export var board: BoardManager = null
@export var hand_holder: PanelContainer = null
var selected_coin = ""
var coin_from_hand = false
var selected_hex: BuildableHex = null
@export var player_id = 1
var hand = ["Archer", "Archer", "Archer", "Archer"]
var army = ["Archer", "Pikeman", "Scout", "Bannerman"]

var units_in_play = {}

func select_coin(coin, from_hand):
	board.wipe_actions()
	coin_from_hand = from_hand
	selected_coin = coin
	if Global.current_mode == Global.User_Mode.Coin_Placing:
		unlock_deploy()
		return
	if units_in_play[coin]: select_hex(units_in_play[coin])
	else: for hex in board.control_spots:
		if hex.controlled_by == player_id: hex.display_actions(["Deploy"])

func use_coin():
	if !coin_from_hand or Global.current_mode == Global.User_Mode.Coin_Placing: return
	var coin_index = hand.find(selected_coin)
	hand.remove_at(coin_index)
	hand_holder.remove_coin(coin_index)
	$"..".end_turn(self)

func set_hand_lock(value: bool):
	hand_holder.set_lock(value)

func move_unit(hex: BuildableHex):
	units_in_play[selected_coin] = hex

func unlock_deploy():
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

func select_hex(hex):
	selected_hex = hex
	if hex.type == "Control" and hex.controlled_by != player_id: hex.display_actions(["Control"])
	hex.display_actions(["Bolster"])
	for neighbor in board.get_hex_neighbors(hex, false):
		if !neighbor: continue
		if neighbor.has_coin(): neighbor.display_actions(["Attack"])
		else: neighbor.display_actions(["Move"])

func _ready():
	for coin in army:
		units_in_play[coin] = null
	for coin in hand:
		hand_holder.add_coin(coin)
	$"..".register_player(self)
