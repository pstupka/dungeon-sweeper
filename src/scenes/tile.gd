extends Node2D

onready var numberSprite = $Number
onready var chest = $Chest
onready var flag = $Flag
onready var bomb = $Bomb
onready var smoke_particles = $Bomb/SmokeParticles

var explosion_scene = preload("res://src/scenes/explosion.tscn")

var id = 0
var number = 0 setget set_number
var is_covered = true
var flagged = false
var is_bomb = false 

var neighbors : Array

var debug = false


func _ready():
	set_number(0)
	Globals.connect("boom", self, "force_explode")
	add_to_group("Tiles")


func debug_uncover() -> void:
	debug = not debug
	if not is_covered: return
	
	if is_bomb:
		bomb.visible = not bomb.visible 
	elif number != 0:
		numberSprite.visible = not numberSprite.visible 
	chest.visible = not chest.visible


func uncover() -> void:
	if not flagged:
		is_covered = false
		if not is_bomb:
			if number != 0: numberSprite.show()
			Globals.tiles_uncovered += 1
		
		chest.hide()
		
		if number == 0 and not is_bomb:
			for tile_id in get_neighbours_ids():
				var tile = Globals.board_array[tile_id]
				if tile.is_covered:
					tile.uncover()


func toggle_flag() -> void:
	if is_covered:
		flagged = not flagged
		flag.visible = flagged


func get_neighbours_ids() -> Array:
	if not neighbors.size(): 
		for i in [-1, 0, 1]:
			for j in [-1, 0, 1]:
				if i == 0 and j == 0: continue
				var coord = Vector2(id % Globals.width + j, id / Globals.width + i)

				if coord.x < 0 or coord.x >= Globals.width or coord.y < 0 or coord.y >= Globals.height:
					continue
				if coord.y * Globals.width + coord.x == id:
					continue
				neighbors.append(coord.y * Globals.width + coord.x)
	return neighbors


func boom() -> void:

	var tween_rand_time = randf() * 0.4 - 0.2
	
	var tween = create_tween().set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	tween.tween_property(bomb, "scale", Vector2(2.5, 2.5), 2.0 + tween_rand_time)
	tween.parallel().tween_method(self, "set_random_bomb_offset", 1, 5, 2.0 + tween_rand_time)
	tween.tween_callback(self, "spawn_explosion")
	tween.tween_callback(smoke_particles, "set_emitting", [true]).set_delay(1.0)



func spawn_explosion() -> void:
	Globals.emit_signal("screen_shake")
	bomb.scale = Vector2.ONE
	bomb.region_rect.position.x = 16
	var explosion = explosion_scene.instance()

	explosion.global_position = global_position
	get_tree().current_scene.add_child(explosion)


func set_random_bomb_offset(amount: float) -> void:
	bomb.position = Vector2(randf(), randf()) * amount


func set_bomb() -> void:
	is_bomb = true
	add_to_group("Bombs")


func set_number(num : int) -> void:
	number = num % 10
	numberSprite.region_rect.position.x = Globals.TILE_W * number
	if number == 0:
		numberSprite.hide()


func force_explode() -> void:
	if not is_bomb: return
	numberSprite.hide()
	chest.hide()
	bomb.show()
	boom()


func _on_Control_gui_input(event):
	if event is InputEventMouseButton:
		if debug: return
		if event.is_action_pressed("left_click"):
			Globals.emit_signal("initial_tile_clicked", id)
			uncover()
			if not flagged and is_bomb:
				get_tree().call_group("Bombs", "force_explode")
				Globals.emit_signal("game_over")
		if event.is_action_pressed("right_click"):
			toggle_flag()
