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

var effect_memory = {}


func tick():
	if enabled:		
		_process_sensors()		
		_process_events()
		_update_state()		
			
			
func _process_sensors():
	# a simple code for emiting events based on sensed effects like shots, hits around etc.
	# as some kind of presistance is needed to not react on the same effect multiple times	
	for effect_id in body_sensors.effects:
		if not effect_id in effect_memory:
			effect_memory[effect_id] = 1.0
			var effect = body_sensors.effects[effect_id]
			if effect.body is ShotFX:
				body_sensors.events.append({
					name = "SHOT",
					direction = effect.direction,
				})
	# hacky way how to clean up the effect memory of any old entries
	# (no effect in sensors means that any effect in memory was reacted to)
	if not body_sensors.effects:
		effect_memory.clear()
			
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
			
	body_sensors.events.clear()


func _update_state():
	if body.state == Character.State.IDLE and randf() < 0.01:
		body_controls.receive_command({
			name = "MOVE",
			position =  Globals.world.get_node("Map/Navigation").get_random_reachable_cell(body.position),				
		})
		
	if body.state == Character.State.IDLE and randf() < 0.005:			
		body_controls.receive_command({
			name = "SAY",
			text = bored_lines[randi() % len(bored_lines)]
		})
					
	if (
		body.state == Character.State.MOVING and 
		not body_sensors.characters.near.empty() and
		randf() < 0.01
	):
		body_controls.receive_command({
			name = "SAY",
			text = greeting_lines[randi() % len(greeting_lines)]
		})
