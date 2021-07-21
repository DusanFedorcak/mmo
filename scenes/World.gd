extends Node2D
class_name WorldNode

var player = null


func _ready():
	Globals.world = self		


func setup_for_server():	
	$Map.setup_for_server()
	

func setup_for_client():
	$Map.setup_for_client()

	
func _process(delta):
	if Network.is_server:		
		for character in $Map/Characters.get_children():
			character.tick(delta)					
		$Map.send_state_update()
		
	if player:
		$PlayerCamera.position = lerp($PlayerCamera.position, player.position, 0.1).floor()
		
	$MouseLocation.position = get_global_mouse_position()

