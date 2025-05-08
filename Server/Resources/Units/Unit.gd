extends Resource
class_name Unit

enum Unit_State {
	Deployed,
	In_Hand,
	Face_Down,
	Face_Up,
	In_Bag
}

@export var name: String
@export var image_name: String
@export var quantity: int
var type: String
var bolsters: Array[Unit] = []
var state: Unit_State
