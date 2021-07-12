extends Tween

export(float) var duration = 1.0
export(float) var strength = 2.0

var _origin = Vector2.ZERO
var _end = Vector2.ZERO
var _stop = false

func animate(from_direction):
	_stop = false
	_origin = get_parent().position
	_end = _origin + from_direction * strength
	interpolate_property(
		get_parent(), "position", _origin, _end, duration * 0.5, Tween.TRANS_LINEAR
	)
	start()


func _on_KickbackTween_tween_all_completed():
	if not _stop:
		_stop = true
		interpolate_property(
			get_parent(), "position", _end, _origin, duration, Tween.TRANS_LINEAR
		)
		start()
