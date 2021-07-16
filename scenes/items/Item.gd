extends Node2D
class_name Item

enum State {
	DROPPED,
	IN_INVENTORY
	EQUIPPED
}

var id = -1
export(State) var state = State.DROPPED setget set_state


func _init():
	id = get_instance_id()


func dump_info():
	return {
		id = id
	}


func setup_form_info(info):
	if "id" in info:
		id = info.id
	
	
func use(by_body: Character):
	pass
	

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

