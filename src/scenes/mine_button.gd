extends Button
class_name MineButton

var id := -1

func _init(new_id:int = -1):
	id = new_id


func _ready():
	pass # Replace with function body.


func call_neighbours():
	print(str(id), " Called")
	for i in [-1, 0, 1]:
		for j in [-1, 0, 1]:
			if i == 0 and j == 0: continue
			var coord = Vector2(id % Globals.width + i, id / Globals.height + j)
			if coord.x < 0 or coord.x >= Globals.width or coord.y < 0 or coord.y >= Globals.height:
				continue
			
			if Globals.board_array[coord.y * Globals.width + coord.x].disabled:
				continue
			
			if Globals.board_array[coord.y * Globals.width + coord.x].text == "":
				Globals.board_array[coord.y * Globals.width + coord.x].call_neighbours()
