extends PanelContainer

@export var board: BoardManager = null

func on_mode_select(mode):
	if Global.current_mode == Global.User_Mode.Board_Edit:
		board.set_edit_mode(false)
	match mode:
		"View":
			Global.current_mode = Global.User_Mode.View
		"Board-Edit":
			Global.current_mode = Global.User_Mode.Board_Edit
			board.set_edit_mode(true)
