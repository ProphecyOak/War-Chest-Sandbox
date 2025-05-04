@tool
extends Polygon2D

const hex_ratio = 1.1547

@export var hex_height = 100:
	set(new_height):
		hex_height = new_height
		var hex_width = hex_height * hex_ratio
		set_polygon(PackedVector2Array([
			Vector2(hex_width / 4.0, 0),
			Vector2(hex_width / 4.0 * 3.0, 0),
			Vector2(hex_width, hex_height / 2.0),
			Vector2(hex_width / 4.0 * 3.0, hex_height),
			Vector2(hex_width / 4.0, hex_height),
			Vector2(0, hex_height / 2.0),
		]))
		offset = Vector2(
			-hex_width/2.0,
			-hex_height/2.0
		)
