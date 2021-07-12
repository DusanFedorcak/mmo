extends KinematicBody2D
class_name Character

const AI_TICK = 0.1
var ai_accum = 0

var is_puppet = false

var id = -1
var char_name = "Name" setget set_char_name
var template = 0

var health = 100


signal hit(gun, from_direction, at_point)


var animation = null
var color = Color.black


enum State {
	IDLE = 0,
	MOVING = 1,
	DEAD = 2
}

var state = State.IDLE


export(float) var walking_speed = 40.0
export(float) var running_speed = 80.0

var facing_direction: Vector2 = Vector2.DOWN
var motion_direction: Vector2 = Vector2.ZERO
var running = false


var current_item = null

var HitFXScene = preload("res://HitFX.tscn")

func set_char_name(n):
	char_name = n
	$Icons/Name.text = char_name


func set_motion(direction, _running=false):
	running = _running
	motion_direction = direction.normalized() if direction != Vector2.ZERO else Vector2.ZERO
	

func _ready():		
	$CollisionShape.disabled = is_puppet
	$Icons/Speaking.visible = false
	color = Assets.get_random_color()
	$Icons/Speaking.modulate = color
	connect("hit", self, "_on_hit")
	
	
func _physics_process(delta):
	if not is_puppet:
		match state:					
			State.MOVING:
				var speed = walking_speed if not running else running_speed
				move_and_slide(motion_direction * speed)				
			State.IDLE:
				pass
	
	
func _process(delta):
	if not is_puppet:
		ai_accum += delta
		while ai_accum > AI_TICK:				
			$Sensors.tick()
			$AI.tick()		
			$Controls.tick()
			ai_accum -= AI_TICK		
		
	_update_animation()	
	
	
func _resolve_animation(direction: Vector2):	
	var animation = "down"	
	if abs(direction.x) > 0.0:
		animation = "right" if direction.x > 0.0 else "left"
	if abs(direction.y) > abs(direction.x):
		animation = "down" if direction.y > 0.0 else "up"

	return animation


func _update_animation():	
	match state:
		State.MOVING:
			animation = _resolve_animation(motion_direction)
			$Shape.speed_scale = 2.0 if running else 1.5
			$Shape.play("walk_" + animation)
		State.IDLE:			
			animation = _resolve_animation(facing_direction)
			$Shape.play("walk_" + animation)
			$Shape.stop()
		State.DEAD:
			$Shape.stop()	
			

func dump_state():
	return {					
		state = state,		
		facing_direction = facing_direction,
		motion_direction = motion_direction,
		runing = running,
		position = self.position,		
	}


func update_state(_state):	
	state = _state.state	
	facing_direction = _state.facing_direction
	motion_direction = _state.motion_direction
	running = _state.runing
	position = _state.position


remotesync func say(text):
	$Icons/Speaking.text = text
	$Icons/Speaking.visible = true
	$Icons/Speaking/SpeakingTimer.wait_time = len(text.split(" ")) * 0.5
	$Icons/Speaking/SpeakingTimer.start()
	
	
remotesync func equip(item_name):
	if current_item:
		current_item.visible = false
		current_item = null
		
	if item_name:
		var item = $Inventory.get_node_or_null(item_name)
		if item:			
			current_item = item
			current_item.visible = true
			
			
func _on_hit(gun, from_direction, at_point):			
	if state != State.DEAD:
		health -= gun.damage
		if health <= 0:		
			state = State.DEAD
			rpc("show_death")
		else:
			$AI.add_event({
				name = "HIT"
			})
									
	rpc("show_hit", from_direction, at_point)		
		
	
	
remotesync func show_hit(from_direction, at_point):		
	var hit_fx = HitFXScene.instance()
	hit_fx.position = at_point
	if state != State.DEAD:
		hit_fx.start_color = Color.red	
		$Shape/KickbackTween.animate(from_direction)
	EventBus.emit_signal("fx_created", hit_fx)
	

remotesync func show_death():
	say("GASP!")
	$Shape/DeathTween.animate()
	$Shape.modulate = Color.lightgray


func _on_SpeakingTimer_timeout():
	$Icons/Speaking.visible = false


func _on_Picker_area_entered(area):
	$Icons/Hover.visible = true	


func _on_Picker_area_exited(area):
	$Icons/Hover.visible = false



	
