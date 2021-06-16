extends "res://Character.gd"


var waypoint_offset = 0.0
var path = null setget set_path


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
	$CollisionShape.disabled = false
	waypoint_offset = $CollisionShape.shape.radius
	
	
func _get_nearest_waypoint():
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
	var waypoint = _get_nearest_waypoint()
	if waypoint:
		set_motion(waypoint - position, true)
	else:
		set_motion(Vector2.ZERO)
		$WorldIcons/Target.visible = false
		
		
func dump_state():
	return {
		name = char_name,
		position = self.position,
		motion_direction = motion_direction,
		runing = running,
	}
		
		
func _process(delta):
	_follow_path()	
	var speed = walking_speed if not running else running_speed
	move_and_slide(motion_direction * speed, Vector2(1, 1))
	
	_update_animation()
	$WorldIcons.position = -position
