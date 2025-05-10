extends VBoxContainer

var clients: Dictionary[int, HBoxContainer]

@export var web_socket: WebSocketServer = null

func client_connected(peer_id: int):
	if peer_id in clients.keys(): return
	var new_client = HBoxContainer.new()
	add_child(new_client)
	clients[peer_id] = new_client
	var newLabel = Label.new()
	new_client.add_child(newLabel)
	newLabel.text = str(peer_id)
	newLabel.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	var prod_button = Button.new()
	new_client.add_child(prod_button)
	prod_button.text = "Prod"
	prod_button.pressed.connect(on_prod.bind(peer_id))

func client_disconnected(peer_id: int):
	if !(peer_id in clients.keys()): return
	remove_child(clients[peer_id])
	clients[peer_id].queue_free()
	clients[peer_id] = null

func on_prod(peer_id: int):
	web_socket.send_JSON({"op":"test_prod"}, peer_id)

func clear_clients():
	for n in get_children(): remove_child(n)
