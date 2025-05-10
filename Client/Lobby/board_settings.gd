extends VBoxContainer

signal board_selected(board_path)

var is_host = false:
	set(new_value):
		is_host = new_value
		$BoardSelect/OptionButton.disabled = !is_host
		$BoardSelect/LoadBoard.disabled = !is_host

func on_board_selected():
	board_selected.emit($BoardSelect/OptionButton.get_selected_id())
