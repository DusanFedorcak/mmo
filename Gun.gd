extends Node2D

var ShotFXScene = preload("res://ShotFX.tscn")

const AIM_SPREAD = deg2rad(10.0)
	
func use(by_body: Character):	
	var aim_angle = by_body.facing_direction.angle() + AIM_SPREAD * (randf() * 2.0 - 1.0)
	#first, create shot effect	
	rpc("create_shot_effect", by_body.position + Vector2(0, -16), aim_angle)
	
	#second, test whether something was hit
	$ShootLine.clear_exceptions()
	$ShootLine.add_exception(by_body)
	$ShootLine.add_exception(by_body.get_node("Picker"))	
	$ShootLine.rotation = aim_angle
	$ShootLine.force_raycast_update()
	
	var hit = $ShootLine.get_collider()
	if hit:		
		#if so, pass the info to the target
		var hit_node = hit.get_parent()		
		hit_node.emit_signal("hit", self, by_body.facing_direction, $ShootLine.get_collision_point())		
					

remotesync func create_shot_effect(at_point, in_direction):
	var shot_fx = ShotFXScene.instance()
	shot_fx.position = at_point
	shot_fx.rotation = in_direction
	EventBus.emit_signal("fx_created", shot_fx)				
