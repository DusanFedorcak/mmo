extends Node
class_name Need

export var initial_score = 0.0

onready var score = initial_score
onready var plan = []

onready var body: Character = $"../../.."
onready var planner: ActionPlanner = $"../../Planner"
onready var actions: CharacterActions = $"../../Planner/Actions"


func tick():
	pass


func execute():
	pass
	
	
static func _sort(a, b):
	return a.score > b.score
	

func dump_debug_info():		
	var plan_str = ""
	if plan:
		var _act_str = PoolStringArray()
		for a in plan:
			_act_str.append(Action.pretty_print(a))		
		plan_str = "--- CURRENT PLAN ---\n%s\n" % _act_str.join("\n")		
	
	return (		
		"--- NEED ---\n" +
		"name: %s\n" % name +
		"has_plan: %s\n" % ("yes" if plan else "no") +
		plan_str
	)
