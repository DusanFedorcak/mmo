extends Reference
class_name Action

var name: String
var pre: Array
var post: Condition
var cost: float

func _init(_name, _pre, _post, _cost):
	name = _name
	pre = _pre
	post = _post
	cost = _cost
	
	
func _get_assignment(goal: Condition):
	var assignment = {}
	for i in len(post.params):
		var v_name = post.params[i].name
		if v_name:			
			assignment[v_name] = goal.params[i]
	return assignment
	
	
func try_satisfy(goal: Condition):
	if post.satisfies(goal):			
		var assignment = _get_assignment(goal)
		var new_pre = []
		for c in pre:
			new_pre.append(c.realize(assignment))
		return get_script().new(name, new_pre, goal, cost)
		

static func pretty_print(action: Action):
	if action:
		var str_pre = PoolStringArray()
		for c in action.pre:
			str_pre.append(Condition.pretty_print(c))	
		return "<%s cost=%.1f pre=[%s] post=%s>" % [
			action.name, action.cost, str_pre.join(", "), Condition.pretty_print(action.post)
		]
	else:
		return "null"
