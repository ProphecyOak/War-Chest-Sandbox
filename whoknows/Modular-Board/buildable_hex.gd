class_name BuildableHex
extends Node2D

const width = 115.47
const height = 100
const coinOffset = 7
const controlColors = [
	"74cd68", # Green for unclaimed
	"b5a438", # Gold for player 1
	"436666", # Gray-Blue for player 2
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
	if !initialized:
		visible = value
		return
	$Delete.visible = value
	$Actions.visible = !value

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

func resolveAction(action_num):
	var player = $"../..".current_player
	var action = action_set[action_num]
	player.use_coin()
	print("%s from %s" % [action, player.selected_coin])
	match action:
		"Control":
			if type != "Control": return
			controlled_by = player.player_id
			board.wipe_actions()
		"Move":
			var origin = player.selected_hex
			if !origin or !origin.has_coin(): return
			for coin in origin.coin_holder.get_children():
				origin.coin_holder.remove_child(coin)
				coin_holder.add_child(coin)
				coin.set_owner(coin_holder)
				coin.disconnect("pressed", player.select_hex.bind(origin))
				coin.connect("pressed", player.select_hex.bind(self))
			player.move_unit(self)
			coins = origin.coins
			origin.coins = []
			board.wipe_actions()
		"Attack":
			remove_coin()
			board.wipe_actions()
		"Construct":
			pass
		"Deploy":
			add_coin(player)
			player.move_unit(self)
			if Global.current_mode == Global.User_Mode.Coin_Placing:
				assign_action_spot("Bolster", action_num)
				return
			board.wipe_actions()
		"Bolster":
			add_coin(player)
			if Global.current_mode == Global.User_Mode.Coin_Placing: return
			board.wipe_actions()
		"Destroy":
			pass
		"Poison":
			pass
		"Sacrifice":
			pass
		"Shock":
			pass
