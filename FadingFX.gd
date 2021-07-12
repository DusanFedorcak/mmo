extends Node2D

export(float) var fade_time = 0.2
export(Color) var start_color = Color.white

func _ready():	
	$Tween.interpolate_property(
		self, "modulate", start_color, Color.transparent, fade_time, Tween.TRANS_LINEAR, Tween.EASE_IN
	)
	$Tween.start()
	

func _on_Tween_tween_all_completed():
	queue_free()
