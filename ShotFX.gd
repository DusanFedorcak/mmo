extends Node2D

const FADE_TIME = 0.2
var time = 0
	
func _process(delta):
	time += delta
	modulate.a = lerp(1.0, 0, time / FADE_TIME)
	
	if time > FADE_TIME:
		queue_free()
