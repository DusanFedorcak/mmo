extends Node2D
class_name CharacterControls

var WAYPOINT_OFFSET = 16.0
var AVOID_MULT = 5.0

var path = null

onready var body: Character = get_parent()
onready var sensors: CharacterSensors = get_node("../Sensors")
			
			
func _process(delta):
	$WorldIcons.position = -body.position
		
		
func tick():	
	match body.state:		
		Character.State.MOVING:
			var waypoint = _get_nearest_waypoint()
			if waypoint:
				var direction = (waypoint - body.position).normalized()
				direction = _avoid_crowded(direction, AVOID_MULT)
				body.set_motion(direction, true)
				body.facing_direction = body.motion_direction
			else:						
				body.state = Character.State.IDLE
				body.set_motion(Vector2.ZERO)		
		_:
			pass
	

func _avoid_crowded(direction, avoid_multiplier):
	var to_near_people = sensors.get_most_crowded_direction()
	var dot = direction.dot(to_near_people)
	if dot > 0:
		direction += to_near_people.rotated(PI * 0.5) * dot * avoid_multiplier
	return direction					
	
		
func _get_nearest_waypoint():
	if path:
		while true:
			if (body.position - path[0]).length_squared() > WAYPOINT_OFFSET * WAYPOINT_OFFSET:
				return path[0]
			else:
				path.remove(0)
				if path.empty():
					path = null

					return null
	else:
		return null	


# --- REMOTE FUNCTIONS ---


master func receive_command(command):	
	if body.state != Character.State.DEAD:
		match command.name:
			"MOVE":						
				path = Globals.world.get_node("Map/Navigation").get_simple_path(body.position, command.position)				
				body.state = Character.State.MOVING
				$WorldIcons/Target.position = command.position
				$WorldIcons/Path.points = path			
			"TURN_TO":						
				body.state = Character.State.IDLE
				body.facing_direction = (command.position - body.position).normalized()
			"SAY":
				body.rpc("say", command.text)
			"EQUIP":
				body.inventory.rpc("equip", command.item_name)
			"UNEQUIP":
				body.inventory.rpc("equip", null)
			"USE":				
				if body.inventory.current_item:
					body.inventory.current_item.use(body)
			"DROP":
				if body.inventory.current_item:
					body.inventory.rpc("drop_current", body.position)
			"TAKE_NEAREST":
				var nearest_item = sensors.get_nearest_item()
				if nearest_item:
					body.inventory.rpc("take", nearest_item)
			_:
				pass
