extends CanvasLayer

var player = null
var equip_actions = []
var under_mouse = null


func _ready():	
	for i in range(5):
		equip_actions.append("control_equip_%d" % i)


func _unhandled_input(_event):		
	if Network.is_connected and player:
		var commands = []		
				
		if _event.is_action_pressed("control_move"):			
			commands.append({
				name = "MOVE",
				position = get_parent().get_global_mouse_position()
			})			
			
		if _event.is_action_pressed("control_turn_and_use"):						
			commands.append({
				name = "TURN_TO",
				direction = get_parent().get_global_mouse_position() - player.position
			})
			commands.append({
				name = "USE",
			})
				
		for i in range(len(equip_actions)):				
			if _event.is_action_pressed(equip_actions[i]):			
				commands.append({
					name = "EQUIP",
					index = i,
				})	
			
		if _event.is_action_pressed("control_unequip"):		
			commands.append({
				name = "UNEQUIP",
			})
				
		if _event.is_action_pressed("control_drop_item"):			
			commands.append({
				name = "DROP",					
			})
			
		if _event.is_action_pressed("control_take_item"):					
			commands.append({
				name = "TAKE_NEAREST",					
			})
		
		if _event.is_action_pressed("control_speak"):					
			commands.append({
				name = "SAY",					
				text = CharacterAI.bored_lines[randi() % len(CharacterAI.bored_lines)]
			})						
						
		for command in commands:
			#send command to server			
			player.get_node("Controls").rpc_id(1, "receive_command", command)			
		
		if Network.is_server:				
			if _event.is_action_pressed("control_select"):
				EventBus.emit_signal("object_selected", under_mouse)
