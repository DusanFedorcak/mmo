extends Node
class_name Conditions

onready var ai: CharacterAI = get_parent()		


func see(obj: Condition.Variable):
	if obj.tag.begins_with("agent"):
		return see_character(obj)
	else:
		return see_item(obj)


func see_character(_char: Condition.Variable):
	if _char.name:
		return _char.name in ai.body_sensors.characters_map
	else:
		assert(false, "Character tags not implemented!")
	

func see_item(item_id: Condition.Variable):
	pass


func dead(char_id: Condition.Variable):
	return see_character(char_id) and ai.body_sensors.characters_map[char_id].body.state == Character.State.DEAD


func equipped(item_tag: Condition.Variable):
	var current_item = ai.body.inventory.current_item
	return current_item and _compatible_item(current_item.tag, item_tag)


func has(item_tag: Condition.Variable):
	var tags = ai.body.inventory.dump_item_tags()
	for tag in tags:
		if _compatible_item(tag, item_tag):
			return true
	return false


func near(obj_id: Condition.Variable, distance):
	return (
		see_character(obj_id) and ai.body_sensors.characters_map[obj_id].distance < distance
		or
		see_item(obj_id) and ai.body_sensors.items_map[obj_id].distance < distance
	)
	

func _compatible_item(item_tag, other_tag):
	return item_tag.begins_with(other_tag)
