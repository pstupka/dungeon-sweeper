extends Node2D


func _ready():
	$Dust.one_shot = true
	$Debris.one_shot = true
	$Sparks.play("explosion")
