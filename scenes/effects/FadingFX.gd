extends Node2D
class_name Effect

export(float) var duration = 0.2
export(Color) var start_color = Color.white
export(Vector2) var end_position = Vector2.ZERO

var id = -1

func _init():
	id = get_instance_id()


func _ready():	
	$Tween.interpolate_property(
		self, "modulate", start_color, Color.transparent, duration, Tween.TRANS_LINEAR, Tween.EASE_IN
	)
	if end_position != Vector2.ZERO:
		$Tween.interpolate_property(
			self, "position", position, position + end_position, duration, Tween.TRANS_LINEAR, Tween.EASE_IN
		)	
	$Tween.start()
	

func _on_Tween_tween_all_completed():
	queue_free()


func _on_ReactionTimer_timeout():
	$CollisionShape.disabled = not Network.is_server
