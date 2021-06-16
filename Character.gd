extends KinematicBody2D
class_name Character

export(float) var walking_speed = 40.0
export(float) var running_speed = 80.0

var char_name = "Name" setget set_char_name

var motion_direction = Vector2.ZERO
var running = false

var animation = null


#class CharacterState:
#	var name: String
#	var motion_direction : Vector2
#	var runing : bool
#	var position: Vector2


func set_char_name(n):
	char_name = n
	$Icons/Name.text = char_name


func set_motion(direction, _running=false):
	running = _running
	motion_direction = direction.normalized() if direction != Vector2.ZERO else Vector2.ZERO


func _update_animation():
	var new_animation = null

	if abs(motion_direction.x) > 0.0:
		new_animation = "right" if motion_direction.x > 0.0 else "left"
	if abs(motion_direction.y) > abs(motion_direction.x):
		new_animation = "down" if motion_direction.y > 0.0 else "up"

	if animation != new_animation:
		animation = new_animation

		$Shape.speed_scale = 2.0 if running else 1.0
		if not animation:
			$Shape.stop()
		else:
			$Shape.play("walk_" + animation)
