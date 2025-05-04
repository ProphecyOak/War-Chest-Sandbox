class_name BuildableHex
extends Node2D

const width = 115.47
const height = 100
const hexColors = {
	"": "ffffff",
	"Normal": "cab176",
	"Control": "74cd68",
	"Empty": "778d9e"
}

@export var board: BoardManager = null
var type: String = "":
	set(new_type):
		type = new_type
		$"Build Options".set_visible(type == "")
		$Backing.color = hexColors[type]
		

var initialized: bool = false
var coordinates: Vector2i = Vector2i(0,0):
	set(newCoords):
		coordinates = newCoords
		$Label.text = "(%s, %s)" % [coordinates.x, coordinates.y]

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
