extends "res://scenes/items/Item.gd"

var ShotFXScene = preload("res://scenes/effects/ShotFX.tscn")

export(float) var aim_spread = 10.0
export(float) var cooldown = 0.1
export(float) var damage = 25.0

func _init():	
	scene = "Gun"

func use(by_body: Character):
	if $CooldownTimer.is_stopped():			
		$CooldownTimer.start(cooldown)
		
		var aim_angle = by_body.facing_direction.angle() + deg2rad(aim_spread) * (randf() * 2.0 - 1.0)
		#first, create shot effect	
		rpc("create_shot_effect", by_body.position + Vector2(0, -16), aim_angle)
		
		#second, test whether something was hit
		$ShootLine.clear_exceptions()
		$ShootLine.add_exception(by_body)
		$ShootLine.add_exception(by_body.get_node("HitBox"))	
		$ShootLine.rotation = aim_angle
		$ShootLine.force_raycast_update()
		
		var hit = $ShootLine.get_collider()
		if hit:		
			#if so, pass the info to the target
			var hit_node = hit.get_parent()		
			hit_node.emit_signal("hit", self, by_body.facing_direction, $ShootLine.get_collision_point())		


# --- REMOTE FUNCTIONS ---
					

remotesync func create_shot_effect(at_point, in_direction):
	var shot_fx = ShotFXScene.instance()
	shot_fx.position = at_point
	shot_fx.rotation = in_direction
	EventBus.emit_signal("fx_created", shot_fx)				
