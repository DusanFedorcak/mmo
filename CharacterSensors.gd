extends Node2D
class_name CharacterSensors

export(float) var FOV = PI * 0.5
const NEAR_BODY_DISTANCE = 50

onready var body: Character = get_parent()
var show_senses = false

var seen_characters = []
var near_characters = []

func tick():	
	var near_bodies = $Sight.get_overlapping_bodies()
	seen_characters.clear()
	near_characters.clear()
	
	for other_body in near_bodies:
		if other_body == body or not other_body is Character:
			continue		
		if abs(body.facing_direction.angle_to(other_body.position - body.position)) < FOV * 0.5:
			seen_characters.append(other_body)
		if body.position.distance_squared_to(other_body.position) < NEAR_BODY_DISTANCE * NEAR_BODY_DISTANCE:
			near_characters.append(other_body)
				
	if show_senses:
		update()
		
		
func get_most_crowded_direction():
	var result = Vector2.ZERO
	for _char in near_characters:
		var dir = _char.position - body.position
		var dist = dir.length()
		if dist > 0:
			result += dir / dist * inverse_lerp(NEAR_BODY_DISTANCE, 0, dist)				
	return result / len(near_characters) if not near_characters.empty() else Vector2.ZERO

			
func _draw():	
	if show_senses:	
		for _char in near_characters:
			draw_circle(_char.position - body.position, 10, Color.white)
		
		draw_line(Vector2.ZERO, get_most_crowded_direction() * 20, Color.red)
