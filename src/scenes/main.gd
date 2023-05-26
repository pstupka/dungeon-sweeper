extends Node2D

onready var tiles = $Tiles
onready var game_over_overlay = $GameOverOverlay
onready var bombs_control = $"%Bombs"
onready var width_control = $"%Width"
onready var height_control = $"%Height"



var tile = preload("res://src/scenes/tile.tscn")
var bombs_ready := false


# Called when the node enters the scene tree for the first time.
func _ready():
	randomize()
	initialize_board(Globals.width, Globals.height)
	Globals.connect("initial_tile_clicked", self, "set_bombs", [], CONNECT_ONESHOT)
	Globals.connect("game_over", self, "game_over")
	
	width_control.value = Globals.width
	height_control.value = Globals.height
	bombs_control.value = Globals.bombs


func _input(event):
	if event.is_action_pressed("debug_uncover"):
		get_tree().call_group("Tiles", "debug_uncover")


func initialize_board(width: int, height: int) -> void:
	Globals.board_array = []
	Globals.bombs_array = []
	Globals.tiles_uncovered = 0
	
	Globals.width = min(Globals.width, Globals.MAX_WIDTH)
	Globals.height = min(Globals.height, Globals.MAX_HEIGHT)
	tiles.position.x += (Globals.MAX_WIDTH - Globals.width) * (Globals.TILE_W + Globals.TILE_W_OFFSET) / 2
	tiles.position.y += (Globals.MAX_HEIGHT - Globals.height) * (Globals.TILE_H + Globals.TILE_H_OFFSET) / 2
	
	for i in height:
		for j in width:
			var tile_instance = tile.instance()
			tiles.add_child(tile_instance)
			tile_instance.owner = self
			tile_instance.position = Vector2(
				j * (Globals.TILE_W + Globals.TILE_W_OFFSET),
				i * (Globals.TILE_H + Globals.TILE_H_OFFSET)
			)
			Globals.board_array.append(tile_instance)
			tile_instance.id = i * width + j


func set_bombs(start_id: int) -> void:
	var rnd := range(Globals.height * Globals.width)
	rnd.remove(start_id)
	rnd.shuffle()
	rnd = rnd.slice(0, Globals.bombs-1)
	
	for bomb_id in rnd:
		Globals.board_array[bomb_id].set_bomb()

		for i in [-1, 0, 1]:
			for j in [-1, 0, 1]:

				var coord = Vector2(bomb_id % Globals.width + j, bomb_id / Globals.width + i)

				if coord.x < 0 or coord.x >= Globals.width or coord.y < 0 or coord.y >= Globals.height:
					continue
				if coord.y * Globals.width + coord.x == bomb_id:
					continue
				Globals.board_array[coord.y * Globals.width + coord.x].number += 1
	bombs_ready = true


func game_over() -> void:
	print("game over")
	game_over_overlay.show()


func _on_RestartButton_pressed():
	get_tree().reload_current_scene()


func _on_Width_value_changed(value):
	Globals.width = value
	bombs_control.max_value = Globals.width * Globals.height


func _on_Height_value_changed(value):
	Globals.height = value
	bombs_control.max_value = Globals.width * Globals.height

func _on_Bombs_value_changed(value):
	Globals.bombs = value
