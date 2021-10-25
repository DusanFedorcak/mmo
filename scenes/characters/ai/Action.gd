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
		

func pretty_print():
	var str_pre = PoolStringArray()
	for c in pre:
		str_pre.append(c.pretty_print())	
	return "<%s cost=%.3f pre=[%s] post=%s>" % [name, cost, str_pre.join(", "), post.pretty_print()]
