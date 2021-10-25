extends Node2D
class_name CharacterAI

# Very rudimentary AI code, just to make NPCs do something
# This is the place where AI magic should happen

onready var body: Character = get_parent()
onready var body_sensors: CharacterSensors = $"../Sensors"
onready var body_controls: CharacterControls = $"../Controls"

var enabled = false

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


func tick():
	$Memory.tick()
	
	if enabled:					
		_process_events()		
		_update_state()		
			
			
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
				body_controls.receive_command({
					name = "SAY",
					text = "OUCH!"
				})
			
			_:
				pass
		
		#TODO: add proper "event handled & timeout" logic to not touch events outside of sensors script.
		body_sensors.events.clear()


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

func _test_condition(condition: Condition):	
	return $Conditions.callv(condition.name, condition.params)
		
		
func _perform_action(action: Action):	
	$Actions.call(action.name)
	return _test_condition(action.post)
	

func _test():	
	print(_perform_action($Actions._get_actions()[0]))
	
	
	
