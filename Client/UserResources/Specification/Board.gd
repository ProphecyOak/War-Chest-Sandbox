extends Resource
class_name Board

@export var player_count: int = 2
@export var winning_score: int = 6
@export var traversable_hexes: Array[Vector2i] = []
@export var control_spots: Array[Vector2i] = []
@export var starting_spots: Dictionary[Vector2i, int] = {}


func get_JSON():
	return {
		"player_count": player_count,
		"winning_score": winning_score,
		"traversable_hexes": traversable_hexes.map(vec_to_arr),
		"control_spots": format_control_spots(),
	}

func format_control_spots():
	var out = []
	for i in range(player_count+1): out.append([])
	for hex in control_spots:
		if starting_spots.has(hex):
			out[starting_spots[hex]].append(hex)
		else: out[-1].append(hex)
	return out

func vec_to_arr(hex):
	return [hex.x, hex.y]
