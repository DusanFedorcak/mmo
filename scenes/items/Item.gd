extends Node2D
class_name Item

enum State {
	DROPPED,
	IN_INVENTORY
	EQUIPPED
}

var id = -1
#TODO: find better way how to reference a scene by name
export var scene = ""
export(State) var state = State.DROPPED setget set_state
export var tag = ""


static func create_from_info(info):
	var item_scene = Assets.item_scenes[info.scene]
	var item = item_scene.instance()
	item.setup_from_info(info)
	return item


func _init():
	id = get_instance_id()
	

func _ready():	
	assert(scene, "Item scene not filled")		
	assert(tag, "Item tag not filled")		
	name = str(id)

func dump_info():
	# This method and the `setup_from_info()` counterpart 
	# assures that the item node can be correctly recreated on a client by passing the `info` dict.
	return {
		scene = scene,
		id = id,
		state = state,
		position = position,
	}


func setup_from_info(info):
	if "id" in info:
		id = info.id
	name = str(id)
	set_state(info.state)
	position = info.position	
	
	
func use(by_body: Character):
	return false
	

func set_state(s):
	state = s
	match state:
		State.DROPPED:			
			$CollisionShape.disabled = false
			$EquipIcon.visible = false
			$GroundIcon.visible = true
		State.IN_INVENTORY:			
			$CollisionShape.disabled = true
			$EquipIcon.visible = false
			$GroundIcon.visible = false
		State.EQUIPPED:			
			$CollisionShape.disabled = true
			$EquipIcon.visible = true
			$GroundIcon.visible = false

