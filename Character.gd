extends KinematicBody2D
class_name Character

export(float) var walking_speed = 40.0
export(float) var running_speed = 80.0

var char_name = "Name" setget set_char_name

var waypoint_offset = 0.0
var path = null setget set_path

var motion_direction = Vector2.ZERO
var running = false

var animation = null


func set_char_name(n):
	char_name = n
	$Icons/Name.text = char_name


func set_path(p):
	path = p
	if path:
		#$WorldIcons/Path.points = path
		#$WorldIcons/Path.visible = true
		$WorldIcons/Target.visible = true
		$WorldIcons/Target.position = path[-1].floor()
	else:
		#$WorldIcons/Path.visible = false
		$WorldIcons/Target.visible = false


func _ready():
	waypoint_offset = $CollisionShape.shape.radius


func get_nearest_waypoint():
	if path:
		while true:
			if (position - path[0]).length_squared() > waypoint_offset * waypoint_offset:
				return path[0]
			else:
				path.remove(0)
				if path.empty():
					path = null

					return null
	else:
		return null


func _follow_path():
	var waypoint = get_nearest_waypoint()
	if waypoint:
		set_motion(waypoint - position, true)
	else:
		set_motion(Vector2.ZERO)
		$WorldIcons/Target.visible = false


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


func _process(delta):
	_follow_path()
	_update_animation()
	$WorldIcons.position = -position

	var speed = walking_speed if not running else running_speed
	move_and_slide(motion_direction * speed, Vector2(1, 1))



