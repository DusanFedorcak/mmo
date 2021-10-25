extends Node
class_name Actions

onready var ai: CharacterAI = get_parent()	

static func _get_actions():
	return [
		Action.new(
			"pickup", 
			[Condition.new("near", ["X", 5.0])], 
			Condition.new("has", ["X"]), 
			1.0
		),
		Action.new(
			"equip", 
			[Condition.new("has", ["X"])], 
			Condition.new("equipped", ["X"]), 
			1.0
		),
		Action.new(
			"approach", 
			[Condition.new("know_pos", ["X"])], 
			Condition.new("near", ["X", "E"]), 
			1.0
		),
		Action.new(
			"locate", 
			[Condition.new("know_pos", ["X"])], 
			Condition.new("see", ["X"]), 
			1.0
		),
		Action.new(
			"shoot_at",
			[Condition.new("see", ["X"]), Condition.new("equipped", ["X:weapon:ranged"])],
			Condition.new("dead", ["X"]),
			1.0
		)
	]
	
func pickup(item_id):
	ai.body_controls.receive_command({
		name="TAKE",
		item_id= item_id
	})
	
func equip(item_id):
	ai.body_controls.receive_command({
		name="EQUIP",
		item_id= item_id
	})

