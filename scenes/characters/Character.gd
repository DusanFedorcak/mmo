extends KinematicBody2D
class_name Character

const AI_TICK = 0.1
var ai_accum = 0

var id = -1
var player_id = -1
var char_name = "Name"
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
onready var inventory = get_node("Inventory")

export(float) var walking_speed = 40.0
export(float) var running_speed = 80.0

var facing_direction: Vector2 = Vector2.DOWN
var motion_direction: Vector2 = Vector2.ZERO
var running = false

var HitFXScene = preload("res://scenes/effects/HitFX.tscn")


func set_motion(direction, _running=false):
	running = _running
	motion_direction = direction.normalized() if direction != Vector2.ZERO else Vector2.ZERO
	

func _init():
	id = get_instance_id()


func _ready():			
	$CollisionShape.disabled = not Network.is_server
	$Icons/Speaking.visible = false
	color = Assets.get_random_color()
	$Icons/Speaking.modulate = color
	connect("hit", self, "_on_hit")
	

func tick(delta):
	ai_accum += delta
	while ai_accum > AI_TICK:				
		$Sensors.tick()
		$AI.tick()
		$Controls.tick()
		ai_accum -= AI_TICK
		

func dump_info():
	var info = {
		id = id, 
		player_id = player_id,
		char_name = char_name, 
		template = template, 
		position = position, 
		color = color,
		
	}
	if $Inventory.current_item:
		info.current_item = $Inventory.current_item.name
	return info
	

func setup_from_info(info):
	if "id" in info:			
		id = info.id
	player_id = info.player_id if "player_id" in info else -1
	char_name = info.char_name	
	template = info.template
	position = info.position
	color = info.color
	
	name = str(id)	
	$Icons/Name.text = char_name
	$Shape.frames = Assets.character_sprites[template]
	
	if "current_item" in info:
		$Inventory.equip(info.current_item)
	
	
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
	
	
func _physics_process(delta):	
	if Network.is_server:
		match state:					
			State.MOVING:
				var speed = walking_speed if not running else running_speed
				move_and_slide(motion_direction * speed)				
			State.IDLE:
				pass	

	
func _process(delta):	
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
			if not $Shape/DeathTween.shown:
				_show_death_animation()
			$Shape.stop()
			

func _show_death_animation():
	say("GASP!")
	$Shape/DeathTween.animate()	
	$Shape.modulate = Color.lightgray
			
	
func _on_SpeakingTimer_timeout():
	$Icons/Speaking.visible = false


func _on_Picker_area_entered(area):
	$Icons/Hover.visible = true	


func _on_Picker_area_exited(area):
	$Icons/Hover.visible = false
			
			
func _on_hit(gun, from_direction, at_point):			
	if state != State.DEAD:
		health -= gun.damage
		if health <= 0:		
			state = State.DEAD
			$CollisionShape.disabled = true
			$HitBox/Circle.disabled = true
			EventBus.emit_signal("character_died", id)			
		else:
			$AI.add_event({
				name = "HIT"
			})
									
	rpc("show_hit", from_direction, at_point)		
	
	
# --- REMOTE FUNCTIONS ---


remotesync func say(text):
	$Icons/Speaking.text = text
	$Icons/Speaking.visible = true
	$Icons/Speaking/SpeakingTimer.wait_time = len(text.split(" ")) * 0.5
	$Icons/Speaking/SpeakingTimer.start()
	
	
remotesync func show_hit(from_direction, at_point):		
	var hit_fx = HitFXScene.instance()
	hit_fx.z_index = 100
	hit_fx.position = at_point
	if state != State.DEAD:
		hit_fx.start_color = Color.red	
		$Shape/KickbackTween.animate(from_direction)
	EventBus.emit_signal("fx_created", hit_fx)

