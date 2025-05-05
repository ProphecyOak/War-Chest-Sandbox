extends PanelContainer

@export var player: Node = null

func add_coin(coin):
	$"../Coin Menu".create_coin_button(coin, $HBoxContainer, true)

func remove_coin(index):
	$HBoxContainer.remove_child($HBoxContainer.get_child(index))
	for coin in $HBoxContainer.get_children():
		coin.button_pressed = false
