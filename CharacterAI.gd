extends Node


onready var body: Character = $"../../"
onready var body_controls: CharacterControls = get_parent()
onready var navigation: MyNavigation = $"../../../../Navigation"

var enabled = false

func _ready():
	pass # Replace with function body.


func tick():
	if enabled:
		if body.state == Character.State.IDLE:
			body_controls.receive_command({
				name = "MOVE",
				position = navigation.get_random_empty_cell(),
			})
