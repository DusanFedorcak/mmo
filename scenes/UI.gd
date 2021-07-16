extends CanvasLayer


onready var world_node = $".."
var is_server = false
var player_template = 0

const MAX_PLAYERS = 32
	
	
func _update_player_template():
	$Menu/VBox/PlayerSelection/Appearance.texture = (
		Assets.character_sprites[player_template].get_frame("walk_down", 0)
	)


func _ready():
	Log.register_target(self)
	$Menu/VBox/HBox/PlayerName.text = Assets.get_random_name()
	player_template = randi() % len(Assets.character_sprites)	
	_update_player_template()
	$Menu.visible = true


func _process(delta):
	if delta != 0:
		$Fps.text = str(int(1.0 / delta))	


func parse_server_address():
	var parsed = $Menu/VBox/ServerAddress.text.split(":")
	return { address = parsed[0], port = parsed[1].to_int()}


func _on_Exit_pressed():
	get_tree().quit()


func _unhandled_input(_event):
	if Input.is_action_just_pressed("ui_cancel"):
		$Menu.visible = not $Menu.visible
		
	if Input.is_action_just_pressed("ui_fullscreen"):
		OS.window_fullscreen = not OS.window_fullscreen	
		
	
	if Network.is_connected and world_node.player:
		var commands = []
				
		if Input.is_action_just_pressed("ui_show_senses"):
			var sensors = world_node.player.get_node("Sensors")
			sensors.show_senses = !sensors.show_senses		
		
		if Input.is_mouse_button_pressed(BUTTON_LEFT):			
			commands.append({
				name = "MOVE",
				position = world_node.get_global_mouse_position()
			})
			
		if Input.is_action_just_pressed("mouse_right_click"):						
			commands.append({
				name = "TURN_TO",
				position = world_node.get_global_mouse_position()
			})
			
			if world_node.player.inventory.current_item:
				commands.append({
					name = "USE",
				})
			
		if Input.is_action_just_pressed("ui_select"):
			if not world_node.player.inventory.current_item:
				commands.append({
					name = "EQUIP",
					item_name = "Gun"
				})
			else:
				commands.append({
					name = "UNEQUIP",
				})
		if Input.is_action_just_pressed("ui_drop_item"):			
			commands.append({
				name = "DROP",					
			})
		if Input.is_action_just_pressed("ui_take_item"):			
			commands.append({
				name = "TAKE_NEAREST",					
			})		
						
		for command in commands:
			#send command to server			
			world_node.player.get_node("Controls").rpc_id(1, "receive_command", command)	


func _on_StartServer_pressed():
	if not world_node.player:		
		$Menu/VBox/JoinGame.disabled = true
		$Menu/VBox/StartServer.disabled = true
		$Menu/VBox/Localgame.disabled = true
		$Menu.visible = false
		Network.create_server(parse_server_address().port)
		world_node.setup_for_server()


func _on_JoinGame_pressed():
	if not world_node.player:		
		$Menu/VBox/JoinGame.disabled = true
		$Menu/VBox/StartServer.disabled = true
		$Menu/VBox/Localgame.disabled = true
		$Menu.visible = false

		var server_info = parse_server_address()
		Network.connect_server(
			$Menu/VBox/HBox/PlayerName.text, player_template, server_info.address, server_info.port
		)


func log_message(message):
	$Console/Output.text += "\n" + message


func _on_Randomize_pressed():
	$Menu/VBox/HBox/PlayerName.text = Assets.get_random_name()


func _on_PreviousChar_pressed():
	player_template = (player_template - 1) % len(Assets.character_sprites)
	_update_player_template()


func _on_NextChar_pressed():
	player_template = (player_template + 1) % len(Assets.character_sprites)
	_update_player_template()


func _on_RandomizeTemplate_pressed():
	player_template = randi() % len(Assets.character_sprites)	
	_update_player_template()


func _on_Localgame_pressed():
	if not world_node.player:		
		$Menu/VBox/JoinGame.disabled = true
		$Menu/VBox/StartServer.disabled = true
		$Menu/VBox/Localgame.disabled = true
		$Menu.visible = false

		var server_info = parse_server_address()
		Network.create_server(parse_server_address().port)
		world_node.setup_for_server()
		EventBus.emit_signal("player_registered", 1, { 
			name = $Menu/VBox/HBox/PlayerName.text,
			template = player_template
		})
		
		
