extends VBoxContainer

signal board_selected(board)

var board_paths = {"Default": "res://UserResources/Boards/Default.tres"}


var is_host = false:
	set(new_value):
		is_host = new_value
		$BoardSelect/OptionButton.disabled = !is_host
		$BoardSelect/LoadBoard.disabled = !is_host

func _ready():
	for key in board_paths.keys():
		$BoardSelect/OptionButton.add_item(key)
	$BoardSelect/OptionButton.select(0)

func on_board_selected():
	var board_path = board_paths[$BoardSelect/OptionButton.get_item_text($BoardSelect/OptionButton.selected)]
	var board = load(board_path)
	board_selected.emit(board)
