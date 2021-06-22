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

var motion_direction = Vector2.ZERO
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
		$AI.tick()
		$WorldIcons/Target.visible = state == State.MOVING
		
	_update_animation()
	$WorldIcons.position = -position	


func _update_animation():
	var new_animation = null

	if abs(motion_direction.x) > 0.0:
		new_animation = "right" if motion_direction.x > 0.0 else "left"
	if abs(motion_direction.y) > abs(motion_direction.x):
		new_animation = "down" if motion_direction.y > 0.0 else "up"

	if animation != new_animation:
		animation = new_animation

		$Shape.speed_scale = 2.0 if running else 1.0
		if not animation:
			$Shape.stop()
		else:
			$Shape.play("walk_" + animation)


func dump_state():
	return {		
		id = id,	
		name = char_name,
		template = template,
		state = state,
		position = self.position,
		motion_direction = motion_direction,
		runing = running,
	}


func update_state(_state):	
	state = _state.state
	motion_direction = _state.motion_direction
	running = _state.runing
	position = _state.position
