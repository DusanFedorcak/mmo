extends Node2D
class_name CharacterSensors

const FOV = PI * 0.5
const NEAR_BODY_DISTANCE = 50
const NEAR_ITEM_DISTANCE = 30

onready var body: Character = get_parent()
onready var sight_distance = $Sight/Circle.shape.radius

var objects = []
var objects_map = {}

var characters = []
var items = []

var effects = {}
var effect_memory = {}
var events = []


func _process(delta):
	update()
		

func tick():
	if body.state != Character.State.DEAD:		
		_update_senses()
		_generate_events()			

			
func _update_senses():	
	objects_map.clear()	
	effects.clear()
		
	var near_bodies = $Sight.get_overlapping_bodies()				
					
	for other_body in near_bodies:
		if other_body == body:			
			continue					
					
		var direction = other_body.position - body.position
		var angle = body.facing_direction.angle_to(direction)
						
		var in_sight = (
			abs(angle) < FOV * 0.5 or 
			direction.length_squared() < NEAR_BODY_DISTANCE * NEAR_BODY_DISTANCE
		)
		
		if in_sight:		
			var r = Record.new(other_body, direction, angle)				
			if other_body is Character or other_body is Item:									
				objects_map[other_body.id] = r			
		
		# "hear" only effects caused by other agents 
		if other_body is Effect and other_body.from_id != body.id:
			effects[other_body.id] = Record.new(other_body, direction, angle)
			
	objects = objects_map.values()
	objects.sort_custom(Record, "_sort")			
		
	items.clear()
	characters.clear()
	
	for obj in objects:		
		if obj.body is Character:
			characters.append(obj)
		else:
			items.append(obj)


func get_map():
	return objects_map			


func get_sorted_list():
	return objects
			
				
func _generate_events():
	# A simple code for emiting events based on sensed effects like shots, hits around etc.
	# As effects persist in between ticks, some kind of memory is needed 
	# to not react the the same effect multiple times	
	for effect_id in effects:
		if not effect_id in effect_memory:
			effect_memory[effect_id] = 1.0
			var effect = effects[effect_id]
			if effect.body is ShotFX:				
				events.append({
					name = "SHOT",
					direction = effect.direction,					
				})
				
	# hacky way how to clean up the "effect memory" of any old entries
	# (no effect in sensors means no need to remember anything from previous ticks)
	# TODO: one downside is that a character can lost an effect from sight and see it again before it disappears.
	# Then, multiple reaction to the same effect will occure.
	if not effects:
		effect_memory.clear()
		
		
func get_most_crowded_direction():
	var result = Vector2.ZERO
	var num_near = 0
	for _char in characters:
		if _char.distance > NEAR_BODY_DISTANCE:
			break
		if _char.distance > 0:
			result += _char.direction / _char.distance * inverse_lerp(NEAR_BODY_DISTANCE, 0, _char.distance)					
		num_near += 1
			
	return result / num_near if num_near > 0 else Vector2.ZERO
	

func get_nearest_pickable_item():	
	if items and items[0].distance < NEAR_ITEM_DISTANCE:
		return items[0].body
	else:
		return null
		

func get_pickable_item(item_id):
	if item_id in objects_map and objects_map[item_id].distance < NEAR_ITEM_DISTANCE:
		return objects_map[item_id].body
		

class Record:
	var id
	var tag: String
	var position: Vector2
	
	var distance: float
	var direction: Vector2
	var angle: float	
	var body: KinematicBody2D
		
	func _init(_body, _direction, _angle):
		id = _body.id
		tag = _body.tag				
		position = _body.position
		
		distance = _direction.length()
		direction = _direction
		angle = _angle		
		body = _body
			
	static func _sort(a, b):
		return a.distance < b.distance	
		

# --- DEBUG CODE ---

			
func _draw():	
	if body.show_debug_info:	
		for _obj in objects:			
			draw_circle(_obj.position - body.position, 5.0, Color.yellow)									
		
		draw_line(Vector2.ZERO, get_most_crowded_direction() * 20, Color.red, 2.0)
				
		var b_angle = body.facing_direction.angle()
		draw_line(Vector2.ZERO, Vector2(sight_distance, 0).rotated(b_angle - FOV * 0.5), Color.yellow)
		draw_line(Vector2.ZERO, Vector2(sight_distance, 0).rotated(b_angle + FOV * 0.5), Color.yellow)
		draw_arc(Vector2.ZERO, sight_distance, b_angle - FOV * 0.5, b_angle + FOV * 0.5, 20, Color.yellow)
		

