extends Node2D
class_name CharacterSensors

export(float) var FOV = PI * 0.5
const NEAR_BODY_DISTANCE = 50

onready var body: Character = get_parent()
var show_senses = false

var characters: Dictionary = {
	"seen": {},
	"near": {}
}

var items: Dictionary = {
	"seen": {},
	"near": {}
}

func tick():	
	var near_bodies = $Sight.get_overlapping_bodies()
	
	_clear_sensors()
		
	for other_body in near_bodies:
		if other_body == body:			
			continue					
					
		var direction = other_body.position - body.position
		var angle = body.facing_direction.angle_to(direction)
		var container = _resolve_body_type(other_body)
		
		if abs(angle) < FOV * 0.5:
			container.seen[other_body.id] = _make_record(other_body, direction, angle)
		if direction.length_squared() < NEAR_BODY_DISTANCE * NEAR_BODY_DISTANCE:
			container.near[other_body.id] = _make_record(other_body, direction, angle)		
				
	if show_senses:
		update()
		

func _clear_sensors():
	characters.seen.clear()
	characters.near.clear()
	items.seen.clear()
	items.near.clear()
	

func _resolve_body_type(body):
	if body is Character:
		return characters
	elif body is Item:
		return items
		

func _make_record(body, direction, angle):
	return {
		body = body,
		direction = direction,
		angle = angle,
		distance = direction.length()
	}
		
func get_most_crowded_direction():
	var result = Vector2.ZERO
	for _char in characters.near.values():		
		if _char.distance > 0:
			result += _char.direction / _char.distance * inverse_lerp(NEAR_BODY_DISTANCE, 0, _char.distance)				
	return result / len(characters.near) if not characters.near.empty() else Vector2.ZERO

			
func _draw():	
	if show_senses:	
		for _char in characters.near.values():
			draw_line(Vector2.ZERO, _char.direction, Color.white, 2.0)		
		for _char in characters.seen.values():
			draw_line(Vector2.ZERO, _char.direction, Color.gray, 2.0)
		
		for _item in items.near.values():
			draw_line(Vector2.ZERO,_item.direction, Color.yellow, 2.0)		
		for _item in items.seen.values():
			draw_line(Vector2.ZERO,_item.direction, Color.darkkhaki, 2.0)
	
		
		draw_line(Vector2.ZERO, get_most_crowded_direction() * 20, Color.red)
