extends "res://scenes/items/Item.gd"

export(float) var aim_spread = 10.0
export(float) var cooldown = 0.1
export(float) var damage = 25.0

var ShotFXScene = preload("res://scenes/effects/ShotFX.tscn")

func _init():	
	rset_config("modulate", MultiplayerAPI.RPC_MODE_REMOTESYNC)

func use(by_body: Character):
	if $CooldownTimer.is_stopped():			
		$CooldownTimer.start(cooldown)		
		rset("modulate", Color.darkgray)		
		
		var aim_angle = by_body.facing_direction.angle() + deg2rad(aim_spread) * (randf() * 2.0 - 1.0)
		#first, create shot effect	
		rpc("create_shot_effect", by_body.id, by_body.position + Vector2(0, -16), aim_angle)
		
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
			hit_node.emit_signal("hit", self, by_body.id, by_body.facing_direction, $ShootLine.get_collision_point())		
			

func can_shoot():
	return $CooldownTimer.is_stopped()


# --- REMOTE FUNCTIONS ---
					

remotesync func create_shot_effect(from_id, at_point, in_direction):
	var shot_fx = ShotFXScene.instance()
	shot_fx.from_id = from_id
	shot_fx.position = at_point
	shot_fx.rotation = in_direction
	EventBus.emit_signal("fx_created", shot_fx)


func _on_CooldownTimer_timeout():
	rset("modulate", Color.white)
