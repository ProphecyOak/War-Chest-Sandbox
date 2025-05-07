class_name BuildableHex
extends Node2D

const width = 115.47
const height = 100
const coinOffset = 7
const controlColors = [
	"74cd68", # Green for unclaimed
	"b5a438", # Gold for player 1
	"436666", # Gray-Blue for player 2
	"660000", # Red for undefined player color
]
const hexColors = {
	"": "ffffff",
	"Normal": "cab176",
	"Control": controlColors[0],
	"Empty": "778d9e"
}

@onready var action_spots = $Actions.get_children()
@onready var coin_holder = $Coins
var coin_prefab = load("res://Modular-Board/Coin.tscn")
var coins = []
@export var board: BoardManager = null
var type: String = "":
	set(new_type):
		if type == "Control" and new_type != "Control": board.control_spots.erase(self) 
		type = new_type
		$"Build Options".set_visible(type == "")
		$Backing.color = hexColors[type]
		if type == "Control": board.control_spots.append(self)

var controlled_by = 0:
	set(new_owner):
		controlled_by = new_owner
		$Backing.color = controlColors[controlled_by]

var initialized: bool = false
var coordinates: Vector2i = Vector2i(0,0):
	set(newCoords):
		coordinates = newCoords
		$Label.text = "(%s, %s)" % [coordinates.x, coordinates.y]

func has_coin():
	return len(coin_holder.get_children()) != 0
	
func get_coin(i):
	return {
		"Node": coin_holder.get_child(i),
		"Coin": coins[i]
	}

func remove_coin():
	coin_holder.remove_child(get_coin(len(coins)-1)["Node"])
	coins.remove_at(len(coins)-1)

func on_initialize(new_type: String):
	if initialized or Global.current_mode != Global.User_Mode.Board_Edit: return
	initialized = true
	type = new_type
	$Delete.visible = true
	board.setup_hex(self)

func deinitialize():
	initialized = false
	type = ""
	$Delete.visible = false

func on_delete():
	board.remove_hex(self)
	
func _ready():
	$Label.visible = Global.DEBUG

func toggle_editing(value: bool):
	$Actions.visible = !value
	if !initialized:
		visible = value
		return
	$Delete.visible = value
	

var action_set = ["","","","",""]
func display_actions(actions):
	var next_empty = action_set.find("")
	for action in actions:
		if next_empty >= 5:
			print("Too many actions trying to render on hex %s" % coordinates)
			return
		assign_action_spot(action, next_empty)
		next_empty += 1

func assign_action_spot(action, spot):
	action_set[spot] = action
	action_spots[spot].texture_normal = load("res://Assets/Action Icons/%s.png" % action)
	action_spots[spot].visible = true

func clear_actions():
	action_set = ["","","","",""]
	for action_num in range(5): action_spots[action_num].visible = false

func add_coin(player):
	var new_coin = coin_prefab.instantiate()
	coin_holder.add_child(new_coin)
	new_coin.set_owner(coin_holder)
	coins.append(player.selected_coin)
	new_coin.position.y -= len(coin_holder.get_children()) * coinOffset - 20
	new_coin.texture_normal = load("res://Assets/Unit Icons/%s.png" % player.selected_coin)
	new_coin.connect("pressed", player.select_hex.bind(self))

var action_logs = {
	"Control": ["%s controls %s", 2],
	"Move": ["%s moves to %s", 2],
	"Attack": ["%s attacks the unit on %s", 2],
	"Construct": ["%s constructs a fort on %s", 2],
	"Deploy": ["%s deploys on %s", 2],
	"Bolster": ["%s bolsters", 1],
	"Destroy": ["%s destroys the fort on %s", 2],
	"Poison": ["%s poisons the unit on %s", 2],
	"Sacrifice": ["%s sacrifices themself", 1],
	"Shock": ["%s shocks the unit on %s", 2]
}

func resolveAction(action_num):
	var player = $"../..".current_player
	var action = action_set[action_num]
	player.use_coin()
	var origin = player.selected_hex
	var log_frame = action_logs[action]
	if log_frame[1] == 1: print(log_frame[0] % [player.selected_coin])
	elif log_frame[1] == 2: print(log_frame[0] % [player.selected_coin, coordinates])
	var select_new_hex = false
	match action:
		"Control":
			if Global.current_mode == Global.User_Mode.Set_Control_Spots:
				controlled_by = int(controlled_by + 1) % (len(controlColors) - 1)
				return
			if type != "Control": print("Invalid Control")
			controlled_by = min(player.player_id + 1, len(controlColors) - 1)
		"Move":
			select_new_hex = true
			if !origin or !origin.has_coin(): print("Invalid Move")
			for coin in origin.coin_holder.get_children():
				origin.coin_holder.remove_child(coin)
				coin_holder.add_child(coin)
				coin.set_owner(coin_holder)
				coin.disconnect("pressed", player.select_hex.bind(origin))
				coin.connect("pressed", player.select_hex.bind(self))
			player.move_unit(self)
			coins = origin.coins
			origin.coins = []
		"Attack":
			remove_coin()
		"Construct":
			pass
		"Deploy":
			origin = self
			add_coin(player)
			player.move_unit(self)
		"Bolster":
			add_coin(player)
		"Destroy":
			pass
		"Poison":
			pass
		"Sacrifice":
			pass
		"Shock":
			pass
	board.wipe_actions()
	if Global.current_mode == Global.User_Mode.Sandbox:
		if select_new_hex: player.select_hex(self)
		else: player.select_hex(origin)
