extends Need


func tick():
	score = 1.0 - body.health / body.MAX_HEALTH
	
	
func execute():	
	if not plan:
		plan = planner.make_plan([Condition.new("healed", [])])	
		
	if plan:
		plan = planner.execute_plan(plan)
		return true
				
	return false

