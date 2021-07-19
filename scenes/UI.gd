extends CanvasLayer


onready var world_node = $".."
	

func _ready():
	Log.register_target(self)
	$Help.visible = false
	_populate_help()


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
				position = world_node.get_global_mouse_position()
			})
			commands.append({
				name = "USE",
			})
								
		if _event.is_action_pressed("control_equip_0"):			
			commands.append({
				name = "EQUIP",
				index = 0,
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
				if action is InputEventKey:
					var key = OS.get_scancode_string(action.scancode)	
					$Help/VBox/Content.text += "\n%s = %s" % [parsed_name, key]
				if action is InputEventMouseButton:
					var key = ""
					match action.button_index:
						1: key = "LMB"
						2: key = "RMB"
						3: key = "MMB"
					$Help/VBox/Content.text += "\n%s = %s" % [parsed_name, key]
				
