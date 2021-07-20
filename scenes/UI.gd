extends CanvasLayer

onready var world_node = $".."

var equip_actions = []
	

func _ready():
	Log.register_target(self)
	$Help.visible = false
	_populate_help()
	for i in range(5):
		equip_actions.append("control_equip_%d" % i)


func _process(delta):
	if delta != 0:
		$Fps.text = str(int(1.0 / delta))	


func _unhandled_input(_event):	
	if _event.is_action_pressed("ui_cancel"):
		$MainMenu.visible = not $MainMenu.visible
		
	if _event.is_action_pressed("control_fullscreen"):
		OS.window_fullscreen = not OS.window_fullscreen
		
	if _event.is_action_pressed("control_show_help") and not $MainMenu.visible:
		$Help.visible = not $Help.visible
			
	if Network.is_connected and world_node.player:
		var commands = []			
				
		if _event.is_action_pressed("control_move"):			
			commands.append({
				name = "MOVE",
				position = world_node.get_global_mouse_position()
			})			
			
		if _event.is_action_pressed("control_turn_and_use"):						
			commands.append({
				name = "TURN_TO",
				direction = world_node.get_global_mouse_position() - world_node.player.position
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
			world_node.player.get_node("Controls").rpc_id(1, "receive_command", command)			
			
		if _event.is_action_pressed("debug_show_senses"):
			var sensors = world_node.player.get_node("Sensors")
			sensors.show_senses = !sensors.show_senses		


func log_message(message):
	$Console/Output.text += "\n" + message
	

func _populate_help():
	for action_name in InputMap.get_actions():
		var parsed_name = action_name.split("control_", false)[0]
		if parsed_name != action_name:		
			for action in InputMap.get_action_list(action_name):			
				var key = ""
				if action is InputEventKey:
					key = OS.get_scancode_string(action.scancode)	
				if action is InputEventMouseButton:					
					match action.button_index:
						1: key = "LMB"
						2: key = "RMB"
						3: key = "MMB"					
				$Help/VBox/Content.text += "%s = %s\n" % [key, parsed_name]				
				
