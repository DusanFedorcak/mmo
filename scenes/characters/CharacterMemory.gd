extends Node2D
class_name CharacterMemory

const PLAIN_SIGHT_FOV = CharacterSensors.FOV * 0.75
const PLAIN_SIGHT_DIST = 300.0


onready var body: Character = $"../.."
onready var sensors: CharacterSensors = $"../../Sensors"

var objects_map = {}
var objects = null

func _process(delta):
	update()


func tick():	
	_update_content()
	

func _update_content():	
	objects = null
			
	for sensed_obj in sensors.get_sorted_list():
		# Update position of remembered objects when you see them again
		if sensed_obj.body.id in objects_map:
			var r = objects_map[sensed_obj.body.id].update(sensed_obj)			
		# or make a new memory record for a new unknown object
		else:
			objects_map[sensed_obj.body.id] = Record.new(sensed_obj)		
	
	# Update distance to remembered objects and 
	# remove all memory records and should be in sight but they are not (i.e. their current position is unknown)
	for record in objects_map.values():
		record.update_distance(body)
		if not record.id in sensors.get_map() and record.in_sight(body):
			objects_map.erase(record.id)
			
			
func get_map():
	return objects_map			


func get_sorted_list():
	if not objects:
		objects = objects_map.values()
		objects.sort_custom(Record, "_sort")
	return objects
	

class Record:
	var id
	var tag: String
	var position: Vector2
	
	var distance_sq: float
	var state: int	
	var time: float
		
	func _init(obj: CharacterSensors.Record):
		id = obj.body.id
		tag = obj.body.tag
		position = obj.body.position
		
		distance_sq = obj.distance * obj.distance
		state = obj.body.state		
		time = OS.get_ticks_msec()

	func in_sight(body):
		var direction = position - body.position
		var angle = body.facing_direction.angle_to(direction)		
		var dist_sq = direction.length_squared() 
		
		return (
			dist_sq < PLAIN_SIGHT_DIST * PLAIN_SIGHT_DIST and abs(angle) < PLAIN_SIGHT_FOV * 0.5
		)
		
	func update(obj: CharacterSensors.Record):
		position = obj.position
		state = obj.body.state		
		time = OS.get_ticks_msec()
		
	func update_distance(body):
		distance_sq = (position - body.position).length_squared()
		
	static func _sort(a, b):
		return a.distance_sq < b.distance_sq


# ---- DEBUG CODE ----		
		
		
func _draw():	
	if body.show_debug_info:	
		for _obj in get_sorted_list():
			var pos = _obj.position.floor() - body.position
			draw_circle(pos, 4.0, Color.magenta)	
			draw_string(Assets.default_font, pos + Vector2(5, 0), str(_obj.id), Color.magenta)	
			draw_string(Assets.default_font, pos + Vector2(5, 10), _obj.tag, Color.white)	
						
		var b_angle = body.facing_direction.angle()
		draw_line(Vector2.ZERO, Vector2(PLAIN_SIGHT_DIST, 0).rotated(b_angle - PLAIN_SIGHT_FOV * 0.5), Color.magenta)
		draw_line(Vector2.ZERO, Vector2(PLAIN_SIGHT_DIST, 0).rotated(b_angle + PLAIN_SIGHT_FOV * 0.5), Color.magenta)
		draw_arc(Vector2.ZERO, PLAIN_SIGHT_DIST, b_angle - PLAIN_SIGHT_FOV * 0.5, b_angle + PLAIN_SIGHT_FOV * 0.5, 20, Color.magenta)				
