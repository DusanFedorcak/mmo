extends "res://scenes/items/Item.gd"

export(float) var strength = 75.0

var HealFXScene = preload("res://scenes/effects/HealFX.tscn")

func use(by_body: Character):
	by_body.rpc("set_health", min(by_body.health + strength, Character.MAX_HEALTH))
	rpc("create_heal_effect", by_body.position + Vector2(0, -45))
	return true
	

remotesync func create_heal_effect(at_point):
	var heal_fx = HealFXScene.instance()
	heal_fx.position = at_point	
	EventBus.emit_signal("fx_created", heal_fx)
