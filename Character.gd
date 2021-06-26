extends KinematicBody2D
class_name Character

var is_puppet = false

var id = -1
var char_name = "Name" setget set_char_name
var template = 0
var animation = null


enum State {
	IDLE = 0,
	MOVING = 1
}

var state = State.IDLE


export(float) var walking_speed = 40.0
export(float) var running_speed = 80.0

var facing_direction: Vector2 = Vector2.DOWN
var motion_direction: Vector2 = Vector2.ZERO
var running = false


func set_char_name(n):
	char_name = n
	$Icons/Name.text = char_name


func set_motion(direction, _running=false):
	running = _running
	motion_direction = direction.normalized() if direction != Vector2.ZERO else Vector2.ZERO
	

func _ready():		
	$CollisionShape.disabled = is_puppet	
	
	
func _physics_process(delta):
	if not is_puppet:
		match state:		
			State.IDLE:
				pass
			State.MOVING:
				var speed = walking_speed if not running else running_speed
				move_and_slide(motion_direction * speed, Vector2(1, 1))				
	
	
func _process(delta):
	if not is_puppet:
		# OPTIMIZE TICK FREQUENCY!
		$Sensors.tick()
		$AI.tick()		
		$Controls.tick()
		$WorldIcons/Target.visible = state == State.MOVING
		$WorldIcons/Path.visible = state == State.MOVING
		
	_update_animation()
	$WorldIcons.position = -position	
	
	
func resolve_animation(direction: Vector2):	
	var animation = null	
	if abs(direction.x) > 0.0:
		animation = "right" if direction.x > 0.0 else "left"
	if abs(direction.y) > abs(direction.x):
		animation = "down" if direction.y > 0.0 else "up"

	return animation

func _update_animation():	
	match state:
		State.MOVING:
			animation = resolve_animation(motion_direction)
			$Shape.speed_scale = 2.0 if running else 1.5
			$Shape.play("walk_" + animation)
		State.IDLE:			
			animation = resolve_animation(facing_direction)
			$Shape.play("walk_" + animation)
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
