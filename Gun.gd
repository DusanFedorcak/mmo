extends Node2D

func _ready():
	pass
	
	
func use(by_body: Character):
	$ShootLine.clear_exceptions()
	$ShootLine.add_exception(by_body)
	$ShootLine.add_exception(by_body.get_node("Picker"))
	$ShootLine.rotation = by_body.facing_direction.angle()
	$ShootLine.force_raycast_update()
	
	var hit = $ShootLine.get_collider()
	if hit:
		var hit_node = hit.get_parent()
		if hit_node is Character:
			hit_node.emit_signal("hit", self)				
