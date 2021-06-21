extends Node
class_name CharacterAI

var waypoint_offset = 0.0
var path = null

onready var body = get_parent()
onready var navigation: Navigation2D = $"../../../Navigation"

enum State {
	IDLE = 0,
	MOVING = 1
}

var state = State.IDLE
		
		
func receive_command(command):
	match command.name:
		"MOVE":			
			path = navigation.get_simple_path(body.position, command.position, false)		
			state = State.MOVING
		_:
			pass
		
		
func tick():
	match state:
		State.IDLE:
			pass
		State.MOVING:
			var waypoint = _get_nearest_waypoint()
			if waypoint:
				body.set_motion(waypoint - body.position, true)
			else:		
				body.set_motion(Vector2.ZERO)
				state = State.IDLE
				
				
func _ready():
	waypoint_offset = $"../CollisionShape".shape.radius
	
		
func _get_nearest_waypoint():
	if path:
		while true:
			if (body.position - path[0]).length_squared() > waypoint_offset * waypoint_offset:
				return path[0]
			else:
				path.remove(0)
				if path.empty():
					path = null

					return null
	else:
		return null
