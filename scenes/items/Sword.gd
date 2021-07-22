extends "res://scenes/items/Gun.gd"

var SlashFXScene = preload("res://scenes/effects/SlashFX.tscn")


remotesync func create_shot_effect(at_point, in_direction):
	var shot_fx = SlashFXScene.instance()
	shot_fx.position = at_point
	shot_fx.rotation = in_direction
	EventBus.emit_signal("fx_created", shot_fx)
