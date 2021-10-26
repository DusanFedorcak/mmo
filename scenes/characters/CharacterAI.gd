extends Node2D
class_name CharacterAI

# Very rudimentary AI code, just to make NPCs do something
# This is the place where AI magic should happen

onready var body: Character = get_parent()
onready var body_sensors: CharacterSensors = $"../Sensors"
onready var body_controls: CharacterControls = $"../Controls"

var enabled = false


enum Need {
	RECREATION = 0,
	SAFETY = 1,
	HEALTH = 2
}

var needs = PoolRealArray([0.4, 0.0, 0.0])
var enemy = null


func tick():
	$Memory.tick()
	
	if enabled:						
		_process_events()	
		_update_needs()
		_update_state()		
		

func _update_state():			
	if body.state == Character.State.IDLE and randf() < 0.01:
		body_controls.receive_command({
			name = "MOVE",
			position = get_node("/root/World/Map/Navigation").get_random_reachable_cell(body.position),				
		})
		
	if body.state == Character.State.IDLE and randf() < 0.005:			
		body_controls.receive_command({
			name = "SAY",
			text = bored_lines[randi() % len(bored_lines)]
		})
					
#	if (
#		body.state == Character.State.MOVING and 
#		not body_sensors.characters.near.empty() and
#		randf() < 0.01
#	):
#		body_controls.receive_command({
#			name = "SAY",
#			text = greeting_lines[randi() % len(greeting_lines)]
#		})
			


func _update_needs():
	needs[Need.HEALTH] = 1.0 - body.health / body.MAX_HEALTH
	needs[Need.SAFETY] = 0.6 if enemy else 0.0


func _process_events():
	for event in body_sensors.events:		
		match event.name:
			"SHOT":				
				if body.state == Character.State.IDLE:
					body_controls.receive_command({
						name = "TURN_TO",
						direction = event.direction
					})
				if randf() < 0.2:
					body_controls.receive_command({
						name = "SAY",
						text = heard_shot_lines[randi() % len(heard_shot_lines)]
					})
			"HIT":
				var text = "OUCH!"							
				if event.from_id in body_sensors.characters_map:
					if not enemy:
						text = "IT WAS YOU!"
						enemy = event.from_id
					
				body_controls.receive_command({
					name = "SAY",
					text = text
				})			
			_:
				pass
		
		#TODO: add proper "event handled & timeout" logic to not touch events outside of sensors script.
		body_sensors.events.clear()
		

func _get_highest_need():	
	var max_need = -1
	var max_need_value = -INF
	
	for n in Need.values():
		if needs[n] > max_need_value:
			max_need_value = needs[n]
			max_need = n
			
	return max_need
		

func _test_condition(condition: Condition):	
	return $Conditions.callv(condition.name, condition.params)
		
		
func _perform_action(action: Action):	
	$Actions.call(action.name)
	return _test_condition(action.post)
	

func dump_debug_info():
	return (
		"--- AI ---\n" + 
		"enabled: %s\n" % enabled +
		"needs: %s\n" % needs + 
		"highest_need: %s\n" % Need.keys()[_get_highest_need()]
	)
	
const bored_lines = [
	"Let's look around",
	"Let's go!",		
	"I'm bored!",
	"This is stupid.",
	"I've nothing to do.",	
	"<Sigh>",
	"I'm really bored!",	
	"So, this is it?",
	"That's all?",
	"Not amusing...",
	"This island is dull.",
	"Look, another boring tree.",
	"There are just trees.",	
]

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
	
	
