extends Tween

export(float) var duration = 1.0
var shown = false


func animate():	
	shown = true
	var _origin = get_parent().position
	var _end = _origin + Vector2(0, 16)
	interpolate_property(
		get_parent(), "position", _origin, _end, duration, Tween.TRANS_LINEAR
	)
	interpolate_property(
		get_parent(), "rotation", 0, -PI * 0.5, duration, Tween.TRANS_LINEAR
	)
	start()	

