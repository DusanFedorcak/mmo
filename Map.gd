extends YSort

var HitFXScene = preload("res://HitFX.tscn")

signal hit(gun, from_direction, at_point)


func _ready():
	connect("hit", self, "_on_hit")


func _on_hit(gun, from_direction, at_point):
	rpc("create_hit_effect", at_point)
	
	
remotesync func create_hit_effect(at_point):	
	var hit_fx = HitFXScene.instance()
	hit_fx.position = at_point
	hit_fx.modulate = Color.cornsilk
	EventBus.emit_signal("fx_created", hit_fx)
