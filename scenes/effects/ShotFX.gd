extends "res://scenes/effects/FadingFX.gd"


func _ready():
	$Blast.scale.y = randf() * 2 - 1
