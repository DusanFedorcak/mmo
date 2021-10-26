extends Node2D
class_name CharacterMemory

const PLAIN_SIGHT_FOV = CharacterSensors.FOV * 0.75
const PLAIN_SIGHT_DIST = 300.0


onready var body: Character = get_node("../..")
onready var sensors: CharacterSensors = get_node("../../Sensors")


class Record:
	var id
	var tag: String
	var position: Vector2		
	var time: float
		
	func _init(obj: CharacterSensors.Record):
		id = obj.body.id
		tag = obj.body.tag
		position = obj.body.position
		time = OS.get_ticks_msec()

	func in_sight(body):
		var direction = position - body.position
		var angle = body.facing_direction.angle_to(direction)		
		var dist2 = direction.length_squared() 
		
		return (
			dist2 < PLAIN_SIGHT_DIST * PLAIN_SIGHT_DIST and	abs(angle) < PLAIN_SIGHT_FOV * 0.5
		)
		
	func update(obj: CharacterSensors.Record):
		position = obj.body.position
		time = OS.get_ticks_msec()


var characters: Dictionary
var items: Dictionary


func tick():	
	_update_content(characters, sensors.characters_map)
	_update_content(items, sensors.items_map)
	

func _update_content(content, sensed_objects):			
	for sensed_obj in sensed_objects.values():
		# Update position of remembered objects when you see them again
		if sensed_obj.body.id in content:
			var r = content[sensed_obj.body.id].update(sensed_obj)			
		# or make a new memory record for a new unknown object
		else:
			content[sensed_obj.body.id] = Record.new(sensed_obj)		
	
	# Remove all memory records and should be in sight but they are not (i.e. their current position is unknown)
	for record in content.values():
		if not record.id in sensed_objects and record.in_sight(body):
			content.erase(record.id)	


func _draw_debug(obj):
	var pos = obj.position.floor() - body.position
	draw_circle(pos, 4.0, Color.magenta)	
	draw_string(Assets.default_font, pos + Vector2(5, 0), str(obj.id), Color.magenta)	
	draw_string(Assets.default_font, pos + Vector2(5, 10), obj.tag, Color.white)	


func _draw():	
	if body.show_debug_info:	
		for _char in characters.values():
			_draw_debug(_char)
						
		for _item in items.values():
			_draw_debug(_item)
			
			
		var b_angle = body.facing_direction.angle()
		draw_line(Vector2.ZERO, Vector2(PLAIN_SIGHT_DIST, 0).rotated(b_angle - PLAIN_SIGHT_FOV * 0.5), Color.magenta)
		draw_line(Vector2.ZERO, Vector2(PLAIN_SIGHT_DIST, 0).rotated(b_angle + PLAIN_SIGHT_FOV * 0.5), Color.magenta)
		draw_arc(Vector2.ZERO, PLAIN_SIGHT_DIST, b_angle - PLAIN_SIGHT_FOV * 0.5, b_angle + PLAIN_SIGHT_FOV * 0.5, 20, Color.magenta)				


func _process(delta):
	update()
