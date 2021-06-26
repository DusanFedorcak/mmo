extends Node


onready var body: Character = get_parent()
onready var body_controls: CharacterControls = $"../Controls"

var enabled = false

func _ready():
	pass # Replace with function body.


func tick():
	if enabled:
		if body.state == Character.State.IDLE and randf() < 0.01:
			body_controls.receive_command({
				name = "MOVE",
				position =  Globals.world.get_node("Map/Navigation").get_random_empty_cell(),
			})
