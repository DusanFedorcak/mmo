extends Position2D

const CAMERA_MARGIN = 10
const CAMERA_SMOOTHING = 0.05


func update_camera(player_position):
	var offset = player_position - position
	var dist2 = offset.length_squared()
	if dist2 > CAMERA_MARGIN * CAMERA_MARGIN:			
		position += CAMERA_SMOOTHING * offset
		$Camera.position = position.floor() - position
