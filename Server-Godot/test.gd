extends Node

func _ready():
	var starting = [Vector2i(0,0), Vector2i(3,3)]
	print(
		JSON.parse_string(
			JSON.stringify(
				starting.map(func (x): return [x.x, x.y])
			)
		).map(func (x): return Vector2i(x[0],x[1]))
	)
