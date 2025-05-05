extends HBoxContainer

@export var coin_size: Vector2 = Vector2(50,50)
@export var toggle_darkness: float = .4
@export var coin_button_container: VBoxContainer = null
@export_dir var coin_icon_path: String
@onready var game: Node2D = $"../../.."
@onready var coin_button_group = load("res://UI/Coin-Select-Button-Group.tres")

func initialize_list():
	for icon in DirAccess.get_files_at(coin_icon_path):
		if !("import" in icon): create_coin_button(icon.substr(0, len(icon) - 4))

func register_player(player):
	$PlayerSelect.add_item(str(player.player_id), player.player_id)

func create_coin_button(icon: String, player: Node=null, destination=coin_button_container):
	var new_button = TextureButton.new()
	destination.add_child(new_button)
	new_button.custom_minimum_size = coin_size
	new_button.ignore_texture_size = true
	new_button.stretch_mode = TextureButton.STRETCH_KEEP_ASPECT_CENTERED
	new_button.toggle_mode = true
	new_button.button_group = coin_button_group
	var normal_image = load("%s/%s.png" % [coin_icon_path, icon]).get_image()
	var toggled_image = darken_image(normal_image)
	if player != null:
		new_button.texture_hover = ImageTexture.create_from_image(normal_image)
		new_button.texture_normal = load("res://Assets/CoinBack.png")
		new_button.connect("pressed", player.select_coin.bind(icon, true))
	else:
		new_button.texture_normal = ImageTexture.create_from_image(normal_image)
		for each_player in game.players:
			new_button.connect("pressed", each_player.select_coin.bind(icon, false))
	new_button.texture_pressed = ImageTexture.create_from_image(toggled_image)

func darken_image(img):
	var darkened = Image.new()
	darkened.copy_from(img)
	for x in range(darkened.get_width()):
		for y in range(darkened.get_height()):
			darkened.set_pixel(x, y, darkened.get_pixel(x, y).darkened(toggle_darkness))
	return darkened

func change_player(index: int):
	game.change_player(index, false)
	game.board.wipe_actions()
	coin_button_group.get_pressed_button().button_pressed = false
	
