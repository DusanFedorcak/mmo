extends "res://Character.gd"


func _ready():
	$CollisionShape.disabled = true
	
	
func update_state(state):
	motion_direction = state.motion_direction
	running = state.runing
	position = state.position
	

func _process(delta):		
	_update_animation()
	$WorldIcons.position = -position
