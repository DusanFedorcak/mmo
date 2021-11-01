extends Node2D
class_name CharacterAI

onready var body: Character = get_parent()
onready var sensors: CharacterSensors = $"../Sensors"
onready var controls: CharacterControls = $"../Controls"

var enabled = false
var needs = []
var _last_need: Need = null


func tick():	
	$Memory.tick()	
	if enabled:						
		_process_events()		
		
		needs = $Needs.get_children()
		for need in needs:			
			need.tick()				
		needs.sort_custom(Need, "_sort")
		
		_last_need = null
		for need in needs:
			if need.execute():
				_last_need = need
				break


func _process_events():
	for event in sensors.events:		
		match event.name:
			"SHOT":				
				if body.state == Character.State.IDLE:
					controls.receive_command({
						name = "TURN_TO",
						direction = event.direction
					})
				if randf() < 0.2:
					controls.receive_command({
						name = "SAY",
						text = heard_shot_lines[randi() % len(heard_shot_lines)]
					})
			"HIT":
				var text = "OUCH!"							
				if event.from_id in sensors.objects_map:
					text = "IT WAS YOU!"
					$Needs/Safety.enemy_id = event.from_id
					
				controls.receive_command({
					name = "SAY",
					text = text
				})			
			_:
				pass
				
	
func _test():
	pass
						

func dump_debug_info():
	var ai_dump = ""
	if enabled:
		var needs_scores = PoolStringArray()		
		for need in needs:		
			needs_scores.append("%s=%.1f" % [need.name.substr(0, 4), need.score])				
		
		ai_dump = (
			"needs: (%s)\n" % needs_scores.join(", ") +
			(_last_need.dump_debug_info() if _last_need else "NO SUCESSFULL NEED EXECUTION!")			
		)
	
	return (
		"--- AI ---\n" + 
		"enabled: %s\n" % enabled +
		ai_dump		
	)
	
	

var greeting_lines = [
	"Hi!",
	"Hello.",
	"Howdy",
	"It's you again.",
	"Hello again.",
	"Just get off my way",
	"Move!",	
]


var heard_shot_lines = [
	"What was that?!",
	"Sh*t!",
	"That's not good!",
	"I'm getting out of here",
	"Watch out!",
	"Oh no!",	
]
