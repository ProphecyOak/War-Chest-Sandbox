extends CenterContainer

@export var web_socket: WebSocketServer = null

func _on_click_start():
	web_socket.start_server()

func _on_click_stop():
	web_socket.stop_server()
