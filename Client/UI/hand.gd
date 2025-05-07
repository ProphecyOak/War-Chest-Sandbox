extends PanelContainer

@export var player: Node = null

func add_coin(coin):
	$"../Coin Menu".create_coin_button(coin, player, $HBoxContainer)

func remove_coin(index):
	$HBoxContainer.remove_child($HBoxContainer.get_child(index))
	for coin in $HBoxContainer.get_children():
		coin.button_pressed = false

func set_lock(value: bool):
	for button in $HBoxContainer.get_children():
		button.disabled = value
