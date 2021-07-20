extends "res://scenes/effects/FadingFX.gd"
class_name ShotFX


func _ready():
	$Blast.scale.y = randf() * 2 - 1
