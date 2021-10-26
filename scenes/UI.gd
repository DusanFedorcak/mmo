extends CanvasLayer

onready var world_node = $".."

func _ready():	
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
		
	if _event.is_action_pressed("control_show_help"):
		$Help.visible = not $Help.visible		
	

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
				
