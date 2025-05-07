extends Node

const DEBUG = false
const savegame_address = "res://Integrated Game/savegame.save"
const player_count = 2

enum User_Mode {
	Board_Edit,
	View,
	Sandbox,
	Set_Control_Spots
}

var current_mode = User_Mode.View
