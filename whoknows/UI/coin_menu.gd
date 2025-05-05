extends PanelContainer

@export var coin_size: Vector2 = Vector2(50,50)
@export var toggle_darkness: float = .4
@export var coin_button_container: VBoxContainer = null
@export_dir var coin_icon_path: String
@export var player_handler: Node = null

func _ready():
	for icon in DirAccess.get_files_at(coin_icon_path):
		if !("import" in icon): create_coin_button(icon)


func create_coin_button(icon: String):
	var new_button = TextureButton.new()
	coin_button_container.add_child(new_button)
	new_button.custom_minimum_size = coin_size
	new_button.ignore_texture_size = true
	new_button.stretch_mode = TextureButton.STRETCH_KEEP_ASPECT_CENTERED
	new_button.toggle_mode = true
	new_button.button_group = load("res://UI/Coin-Select-Button-Group.tres")
	var normal_image = load("%s/%s" % [coin_icon_path, icon]).get_image()
	var toggled_image = darken_image(normal_image)
	new_button.texture_normal = ImageTexture.create_from_image(normal_image)
	new_button.texture_pressed = ImageTexture.create_from_image(toggled_image)
	new_button.connect("pressed", player_handler.select_coin.bind(icon.substr(0, len(icon) - 4)))

func darken_image(img):
	var darkened = Image.new()
	darkened.copy_from(img)
	for x in range(darkened.get_width()):
		for y in range(darkened.get_height()):
			darkened.set_pixel(x, y, darkened.get_pixel(x, y).darkened(toggle_darkness))
	return darkened
	
