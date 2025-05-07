extends PanelContainer

@export var board: BoardManager = null

func on_mode_select(mode):
	for rank in range(board.boardSize.y):
		for file in range(board.boardSize.x):
			var hex = board.hexes[rank][file]
			if hex: hex.clear_actions()
	if Global.current_mode == Global.User_Mode.Board_Edit:
		$"../../..".lock_all_hands()
		board.set_edit_mode(false)
	if Global.current_mode == Global.User_Mode.Set_Control_Spots: board.set_control_mode(false)
	if Global.current_mode == Global.User_Mode.Sandbox: $"../Coin Menu".visible = false
	match mode:
		"View":
			Global.current_mode = Global.User_Mode.View
			$"../../..".unlock_current()
		"Board-Edit":
			Global.current_mode = Global.User_Mode.Board_Edit
			board.set_edit_mode(true)
		"Coin":
			Global.current_mode = Global.User_Mode.Sandbox
			$"../Coin Menu".visible = true
		"Set_Control_Spots":
			Global.current_mode = Global.User_Mode.Set_Control_Spots
			board.set_control_mode(true)
