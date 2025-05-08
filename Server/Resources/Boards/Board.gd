extends Resource
class_name Board

@export var hexagons: Array[Vector2i] = []
@export var control_spots: Dictionary[Vector2i, int] = {}


func get_JSON():
	return {
		"hexagons": hexagons,
		"control_spots": control_spots
	}
