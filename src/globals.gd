extends Node

signal game_over()
signal screen_shake()
signal boom()
signal initial_tile_clicked()


const TILE_W = 16
const TILE_H = 16

const TILE_W_OFFSET = 2
const TILE_H_OFFSET = 2

const MAX_WIDTH = 32
const MAX_HEIGHT = 22

export var width: int = 32
export var height: int = 22
export var bombs: int = 50

var board_array := []
var bombs_array := []

var tiles_uncovered = 0 setget set_tiles_uncovered


func set_tiles_uncovered(val: int) -> void:
	tiles_uncovered = val
	check_win()


func check_win() -> void:
	if tiles_uncovered == width * height - bombs:
		emit_signal("game_over")
		print("WIIIIN")
