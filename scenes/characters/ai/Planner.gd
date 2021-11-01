extends Node
class_name ActionPlanner

	
func make_plan(goals: Array):	
	var plan = []
	var failed_goal = null
	
	while goals:
		var goal = goals.pop_back()
		var satisfied = goal.test($Conditions)		
		if not satisfied:			
			var maybe_action = _get_suitable_action(goal)
			if maybe_action:
				plan.append(maybe_action)
				goals += maybe_action.pre
			else:					
				failed_goal = goal			
				break			
				
	return plan if not failed_goal else null


func execute_plan(plan: Array):				
	# Try top-most action in the plan	
	var action: Action = plan[-1]
	
	# Remove action if already satisfied
	if action.post.test($Conditions):
		plan.pop_back()		
	else:		
		# Test if preconditions are still valid
		var action_params = []
		for c in action.pre:
			var result = c.test($Conditions)
			if not result:
				# Discard plan if any precondition fails				
				return null
			else:
				action_params.append(result)
		#Finally, perform action (but not remove it yet, it might need more executions)
		$Actions.callv(action.name, action_params)
		
	return plan


func _get_suitable_action(goal: Condition):
	for action in $Actions.action_rules:
		var maybe_action = action.try_satisfy(goal)
		if maybe_action:
			return maybe_action
	return null			
	
