extends Node2D
class_name CharacterControls

var WAYPOINT_OFFSET = 16.0
var AVOID_MULT = 3.0

var path = null
var target = null

onready var body: Character = get_parent()
onready var sensors: CharacterSensors = $"../Sensors"
onready var memory: CharacterMemory = $"../AI/Memory"
			
			
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
				target = null	
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
				if not path:
					path = null
					return null
	else:
		return null	
		
		
func _pick_up_item(item):
	if item:
		body.inventory.rpc("pick_up", item.id)
		if item.id in memory.objects_map:
			memory.objects_map.erase(item.id)


# --- REMOTE FUNCTIONS ---


master func receive_command(command):
	# This call goes to server only!
	if body.state != Character.State.DEAD:
		match command.name:
			"MOVE":						
				path = get_node("/root/World/Map/Navigation").get_simple_path(body.position, command.position)				
				target = command.position
				body.state = Character.State.MOVING
				$WorldIcons/Target.position = command.position
				$WorldIcons/Path.points = path
			"TURN_TO":						
				body.state = Character.State.IDLE
				body.facing_direction = command.direction.normalized()
			"SAY":
				body.rpc("say", command.text)
			"EQUIP":
				if body.inventory.get_child_count() > 0:
					var item_id = null
					if "item_id" in command:
						item_id = str(command.item_id)
					elif command.index < body.inventory.get_child_count():
						var item = body.inventory.get_child(command.index)
						item_id = str(item.id) if item else null					
					body.inventory.rpc("equip", item_id)
			"UNEQUIP":
				body.inventory.rpc("equip", null)
			"USE":
				body.inventory.use_current_item()				
			"DROP":
				if body.inventory.current_item:
					body.inventory.rpc("drop_current_item", body.position)
			"PICK_UP_NEAREST":				
				_pick_up_item(sensors.get_nearest_pickable_item())		
			"PICK_UP":
				_pick_up_item(sensors.get_pickable_item(command.item_id))				
			_:
				pass
