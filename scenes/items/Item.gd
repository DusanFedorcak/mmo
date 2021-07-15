extends Node2D
class_name Item

enum State {
	DROPPED,
	IN_INVENTORY
	EQUIPPED
}

var id = self.id
var state = State.DROPPED setget set_state
	
	
func use(by_body: Character):
	pass
	

func set_state(s):
	state = s
	match state:
		State.DROPPED:
			$EquipIcon.visible = false
			$GroundIcon.visible = true
		State.IN_INVENTORY:
			$EquipIcon.visible = false
			$GroundIcon.visible = false
		State.EQUIPPED:
			$EquipIcon.visible = true
			$GroundIcon.visible = false

