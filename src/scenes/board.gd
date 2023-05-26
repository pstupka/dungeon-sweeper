extends Control
onready var grid_container = $GridContainer


# Called when the node enters the scene tree for the first time.
func _ready():
	randomize()
	grid_container.columns = Globals.width
	
	var rnd := []
	for i in Globals.width * Globals.height:
		var button = MineButton.new(i)
		button.size_flags_horizontal = SIZE_EXPAND_FILL
		button.size_flags_vertical = SIZE_EXPAND_FILL
		
		grid_container.add_child(button)
		button.connect("pressed", self, "_on_button_pressed", [button])
		Globals.board_array.append(button)
		rnd.append(i)
	
	rnd.shuffle()
	
	for n in Globals.bombs:
		var bomb_id = rnd[n]
		
		Globals.board_array[bomb_id].text = 'X'
		for i in [-1, 0, 1]:
			for j in [-1, 0, 1]:
				if i == 0 and j == 0: continue
				var coord = Vector2(bomb_id % Globals.width + i, bomb_id / Globals.height + j)
				
				if coord.x < 0 or coord.x >= Globals.width or coord.y < 0 or coord.y >= Globals.height:
					continue
				if Globals.board_array[coord.y * Globals.width + coord.x].text == "X":
					continue
				Globals.board_array[coord.y * Globals.width + coord.x].text = str(int(Globals.board_array[coord.y * Globals.width + coord.x].text) + 1)


func _on_button_pressed(button: Button) -> void:
	if button.text == "":
#		button.call_neighbours()
		return
	button.disabled = true
