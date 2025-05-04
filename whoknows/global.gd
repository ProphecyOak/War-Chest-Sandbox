extends Node

const DEBUG = false
const savegame_address = "res://savegame.save"

enum User_Mode {
	Board_Edit,
	View
}

var current_mode = User_Mode.View
