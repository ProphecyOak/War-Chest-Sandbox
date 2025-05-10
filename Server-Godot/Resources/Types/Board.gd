extends Resource
class_name Board

var hexagons: Array[Vector2i] = []
var control_spots: Dictionary[Vector2i, int] = {}

static func from_JSON(data):
	var keys = data.keys()
	if "hexagons" in keys and "control_spots" in keys:
		return Board.new(
			data["hexagons"].map(func (x): return Vector2i(x[0],x[1])),
			data["control_spots"].map(func (x): return Vector2i(x[0],x[1]))
		)

func _init(hexagons_, control_spots_):
	hexagons = hexagons_
	control_spots = control_spots_

func get_JSON():
	return {
		"hexagons": hexagons.map(func (x): return [x.x, x.y]),
		"control_spots": control_spots
	}
