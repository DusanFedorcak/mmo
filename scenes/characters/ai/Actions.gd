extends Node
class_name CharacterActions

onready var body: Character = $"../../.."
onready var sensors: CharacterSensors = $"../../../Sensors"
onready var controls: CharacterControls = $"../../../Controls"
onready var memory: CharacterMemory = $"../../Memory"

onready var action_rules = [
		Action.new(
			"pickup",			
			[Condition.new("near", ["X", CharacterSensors.NEAR_ITEM_DISTANCE])], 
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
			[Condition.new("know", ["X"])], 
			Condition.new("near", ["X", "E"]), 
			1.0
		),
		Action.new(
			"locate", 
			[Condition.new("know", ["X"])], 
			Condition.new("see", ["X"]), 
			1.0
		),
		Action.new(
			"shoot_at",
			[Condition.new("see", ["X"]), Condition.new("equipped", [":weapon:ranged"])],
			Condition.new("dead", ["X"]),
			1.0
		),
		Action.new(
			"drink_potion",
			[Condition.new("equipped", [":potion:health"])],
			Condition.new("healed", []),
			1.0
		)
	]
	
	
func pickup(item_id):
	controls.receive_command({
		name="PICK_UP",
		item_id=item_id
	})
	
	
func equip(item_id):
	controls.receive_command({
		name="EQUIP",
		item_id=item_id
	})
	
	
func drink_potion(item_id):
	controls.receive_command({
		name="USE",		
	})
	

func approach(obj_id):
	var obj = memory.get_map()[obj_id]
	if not (
		body.state == Character.State.MOVING and 
		(controls.target - obj.position).length_squared() < CharacterSensors.NEAR_ITEM_DISTANCE * CharacterSensors.NEAR_ITEM_DISTANCE
	):		
		controls.receive_command({
			name = "MOVE",
			position = obj.position,
		})
		

func locate(obj_id):
	approach(obj_id)
	
	
func shoot_at(obj_id, gun_id):
	var obj = sensors.get_map()[obj_id]	
	
	if abs(obj.angle) > PI * 0.02:
		controls.receive_command({
			name = "TURN_TO",
			direction = obj.direction,
		})
	elif body.inventory.current_item.can_shoot():
		controls.receive_command({
			name = "USE",			
		})		

	
func wander(move_prob):
	if body.state == Character.State.IDLE and randf() < move_prob:
		controls.receive_command({
			name = "MOVE",
			position = get_node("/root/World/Map/Navigation").get_random_reachable_cell(body.position),				
		})
		
	if body.state == Character.State.IDLE and randf() < 0.005:			
		controls.receive_command({
			name = "SAY",
			text = bored_lines[randi() % len(bored_lines)]
		})

		
const bored_lines = [
	"Let's look around",
	"Let's go!",		
	"I'm bored!",
	"This is stupid.",
	"I've nothing to do.",	
	"<Sigh>",
	"I'm really bored!",	
	"So, this is it?",
	"That's all?",
	"Not amusing...",
	"This island is dull.",
	"Look, another boring tree.",
	"There are just trees.",	
]

