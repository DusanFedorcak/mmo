extends Node
class_name Conditions

onready var body: Character = $"../../.."
onready var sensors: CharacterSensors = $"../../../Sensors"
onready var memory: CharacterMemory = $"../../Memory"


func equipped(tag):
	var current_item = body.inventory.current_item	
	return current_item.id if current_item and Condition.Variable.valid_tag(current_item.tag, tag) else null
		

func has(tag):
	for item in body.inventory.get_children():
		if Condition.Variable.valid_tag(item.tag, tag):
			return item.id
	return null
	
	
func know(tag):
	return _find(tag, memory)
		

func see(tag):	
	return _find(tag, sensors)
	

func near(tag, distance: float):
	return _find(tag, memory, "_test_distance", [distance])
	

func dead(tag):	
	return _find(tag, memory, "_test_state", [Character.State.DEAD])	
	
	
func healed():
	return body.id if body.health > 100.0 else null	
		
		
# --- SUPPPORT FUNCTIONS ---


static func _test_distance(obj, distance):
	return obj.distance_sq < distance * distance
	
	
static func _test_state(obj, state):
	return obj.state == state


func _find(tag, target, filter=null, filter_params=[]):
	if typeof(tag) == TYPE_INT:
		if (
			tag in target.get_map() and 
			(not filter or callv(filter, [target.get_map()[tag]] + filter_params))
		):
			return tag
		else:
			return null
	else:
		for obj in target.get_sorted_list():
			if (
				Condition.Variable.valid_tag(tag, obj.tag) and 
				(not filter or callv(filter, [obj] + filter_params))
			):
				return obj.id
		return null
