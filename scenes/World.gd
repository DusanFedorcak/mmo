extends Node2D
class_name WorldNode

const CAMERA_MARGIN = 10
const CAMERA_SMOOTHING = 0.05

var player = null
var camera_true_position = Vector2.ZERO


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
		var offset = player.position - $PlayerCamera.position
		var dist2 = offset.length_squared()
		if dist2 > CAMERA_MARGIN * CAMERA_MARGIN:
			camera_true_position += CAMERA_SMOOTHING * offset
			$PlayerCamera.position = camera_true_position.floor()
		
	$MouseLocation.position = get_global_mouse_position()

