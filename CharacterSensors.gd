extends Node2D
class_name CharacterSensors

export(float) var FOV = PI * 0.5
const NEAR_BODY_DISTANCE = 50

onready var body: Character = get_parent()
var show_senses = false

var seen_characters: Dictionary = {}
var near_characters: Dictionary = {}

func tick():	
	var near_bodies = $Sight.get_overlapping_bodies()
	seen_characters.clear()
	near_characters.clear()
	
	for other_body in near_bodies:
		if other_body == body or not other_body is Character:
			continue		
		var direction = other_body.position - body.position
		var angle = body.facing_direction.angle_to(direction)
		if abs(angle) < FOV * 0.5:
			seen_characters[other_body.id] = _make_record(other_body, direction, angle)
		if direction.length_squared() < NEAR_BODY_DISTANCE * NEAR_BODY_DISTANCE:
			near_characters[other_body.id] = _make_record(other_body, direction, angle)		
				
	if show_senses:
		update()


func _make_record(body, direction, angle):
	return {
		body = body,
		direction = direction,
		angle = angle,
		distance = direction.length()
	}
		
func get_most_crowded_direction():
	var result = Vector2.ZERO
	for _char in near_characters.values():		
		if _char.distance > 0:
			result += _char.direction / _char.distance * inverse_lerp(NEAR_BODY_DISTANCE, 0, _char.distance)				
	return result / len(near_characters) if not near_characters.empty() else Vector2.ZERO

			
func _draw():	
	if show_senses:	
		for _char in near_characters:
			draw_circle(_char.direction, 10, Color.white)
		
		draw_line(Vector2.ZERO, get_most_crowded_direction() * 20, Color.red)
