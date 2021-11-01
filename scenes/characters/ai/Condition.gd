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
		
	static func from(obj):
		return Variable.new("", obj.id)
		
	func valid(other_var: Variable):		
		return Variable.valid_tag(tag, other_var.tag)
	
	static func valid_tag(tag, other_tag):
		return (
			tag == "" or 
			typeof(other_tag) == TYPE_STRING and other_tag.begins_with(tag)
		)
	
	static func pretty_print(v: Variable):		
		return "%s:%s" % [v.name, v.tag] if v else "null"
					

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
	
	
func test(conditions_node):
	var _params = []
	for p in params:
		_params.append(p.tag)
	return conditions_node.callv(name, _params)

	
static func pretty_print(cond: Condition):	
	if cond:
		var str_params = PoolStringArray()
		for p in cond.params:
			str_params.append(Variable.pretty_print(p))
		return "%s(%s)" % [cond.name, str_params.join(", ")]
	else:
		return "null"
