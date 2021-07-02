extends Node2D


onready var body: Character = get_parent()
onready var body_sensors: CharacterSensors = $"../Sensors"
onready var body_controls: CharacterControls = $"../Controls"

var enabled = false

var bored_lines = [
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

func _ready():
	pass # Replace with function body.


func tick():
	if enabled:
		if body.state == Character.State.IDLE and randf() < 0.01:
			body_controls.receive_command({
				name = "MOVE",
				position =  Globals.world.get_node("Map/Navigation").get_random_empty_cell(),				
			})
			
		if body.state == Character.State.IDLE and randf() < 0.004:			
			body_controls.receive_command({
				name = "SAY",
				text = bored_lines[randi() % len(bored_lines)]
			})
						
		if (
			body.state == Character.State.MOVING and 
			not body_sensors.near_characters.empty() and
			randf() < 0.005
		):
			body_controls.receive_command({
				name = "SAY",
				text = greeting_lines[randi() % len(greeting_lines)]
			})			
			
