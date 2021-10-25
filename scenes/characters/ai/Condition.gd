extends Reference
class_name Condition

var name: String
var params: Array


class Variable:
	var name: String
	var tag	
	
	func _init(_name, _tag):
		name = _name
		tag = _tag
		
	func valid(other_var):		
		return (
			tag == "" or 
			typeof(other_var.tag) == TYPE_STRING and other_var.tag.begins_with(tag)
		)
	
	func pretty_print():
		return "%s:%s" % [name, tag]
					

func _init(_name, _params):
	name = _name
	params = []
	for p in _params:
		match typeof(p):
			TYPE_STRING:			
				var _split = p.split(":", true, 1)		
				assert(len(_split) > 0, "Empty condition not allowed")
				if len(_split) == 1:
					params.append(Variable.new(_split[0], ""))
				else:
					params.append(Variable.new(_split[0], _split[1]))
			TYPE_REAL, TYPE_INT:
				params.append(Variable.new("", p))			

		
func satisfies(goal: Condition):
	if name == goal.name and len(params) == len(goal.params):		
		for i in len(params):
			if not params[i].valid(goal.params[i]):
				return false
		return true
	else:
		return false
		

func realize(assignment: Dictionary):
	var new_params = []
	for p in params:
		if p.name in assignment:
			new_params.append(assignment[p.name])
		else:
			new_params.append(p)
	var realization = get_script().new(name, [])
	realization.params = new_params
	return realization
	
func pretty_print():	
	var str_params = PoolStringArray()
	for p in params:
		str_params.append(p.pretty_print())
	return "%s(%s)" % [name, str_params.join(", ")]
