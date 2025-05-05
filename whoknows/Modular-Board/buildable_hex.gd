class_name BuildableHex
extends Node2D

const width = 115.47
const height = 100
const coinOffset = 40
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
var coins = []
@onready var player = get_node("../../Player")
@export var board: BoardManager = null
var type: String = "":
	set(new_type):
		type = new_type
		$"Build Options".set_visible(type == "")
		$Backing.color = hexColors[type]

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
	coin_holder.remove_child(coin_holder.get_children()[len(coins)-1])
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
	if len(actions) > 5:
		print("Too many actions trying to render on hex %s" % coordinates)
		return
	for action_num in range(len(actions)):
		assign_action_spot(actions[action_num], action_num)

func assign_action_spot(action, spot):
	action_set[spot] = action
	action_spots[spot].texture_normal = load("res://Assets/Action Icons/%s.png" % action)
	action_spots[spot].visible = true

func clear_actions():
	action_set = ["","","","",""]
	for action_num in range(5): action_spots[action_num].visible = false

func resolveAction(action_num):
	var action = action_set[action_num]
	match action:
		"Control":
			if type != "Control": return
			controlled_by = (controlled_by + 1) % (Global.player_count + 1)
		"Move":
			pass
		"Attack":
			pass
		"Construct":
			pass
		"Deploy":
			var new_coin = Sprite2D.new()
			coin_holder.add_child(new_coin)
			coins.append(player.selected_coin)
			new_coin.set_owner(coin_holder)
			new_coin.scale = Vector2(.2,.2)
			new_coin.offset.y -= len(coin_holder.get_children()) * coinOffset - 60
			new_coin.texture = load("res://Assets/Unit Icons/%s.png" % player.selected_coin)
			if Global.current_mode == Global.User_Mode.Coin_Placing: assign_action_spot("Bolster", action_num)
		"Bolster":
			pass
		"Destroy":
			pass
		"Poison":
			pass
		"Sacrifice":
			pass
		"Shock":
			pass
