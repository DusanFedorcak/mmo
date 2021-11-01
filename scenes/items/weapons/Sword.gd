extends "res://scenes/items/weapons/Gun.gd"

var SlashFXScene = preload("res://scenes/effects/SlashFX.tscn")


remotesync func create_shot_effect(from_id, at_point, in_direction):
	var shot_fx = SlashFXScene.instance()
	shot_fx.from_id = from_id
	shot_fx.position = at_point
	shot_fx.rotation = in_direction
	EventBus.emit_signal("fx_created", shot_fx)
