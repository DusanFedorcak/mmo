extends Need

var enemy_id = null


func tick():
	score = 0.6 if enemy_id else 0.0
	

func execute():
	if enemy_id:		
		if not plan:
			plan = planner.make_plan([Condition.new("dead", [enemy_id])])
		if plan:
			plan = planner.execute_plan(plan)
			if plan != null and plan.empty():
				enemy_id = null
		else:
			actions.wander(1.0)
		return true		
	
	return false	
	
func dump_debug_info():
	return .dump_debug_info() + "enemy: %s\n" % enemy_id	
