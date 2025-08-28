extends PanelContainer

var coins_placed = 0

func clear_rack():
	for x in $MarginContainer/HBoxContainer.get_children():
		x.visible = false
	coins_placed = 0

func add_coin(image_id: String):
	if coins_placed >= 3:
		print("You are trying to draw too many coins!")
		return false
	if image_id not in Global.additional_icons["units"].keys():
		print("The icon with id: `%s` has not been provided to this user!" % image_id)
		return false
	var img_texture = Global.additional_icons["units"][image_id]
	var coin_to_change = $MarginContainer/HBoxContainer.get_child(coins_placed)
	coin_to_change.texture_normal = img_texture
	coin_to_change.visible = true
	coins_placed += 1
