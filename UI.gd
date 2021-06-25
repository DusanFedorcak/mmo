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
		if Input.is_mouse_button_pressed(BUTTON_LEFT):			
			var command = {
				name = "MOVE",
				position = world_node.get_global_mouse_position()
			}
						
			#for local play
			if world_node.player.id == 1:
				world_node.player.get_node("Controls").receive_command(command)
			else:
				rpc_id(1, "receive_command", command)
				

remote func receive_command(command):
	var id = get_tree().get_rpc_sender_id()
	var player = world_node.get_character(id)
	if player:
		player.get_node("Controls").receive_command(command)


func _on_StartServer_pressed():
	if not world_node.player:		
		$Menu/VBox/JoinGame.disabled = true
		$Menu/VBox/StartServer.disabled = true
		$Menu/VBox/Localgame.disabled = true
		$Menu.visible = false
		Network.create_server(parse_server_address().port)
		world_node.setup_server()


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
		world_node.setup_server()
		EventBus.emit_signal("player_added", 1, { 
			name = $Menu/VBox/HBox/PlayerName.text,
			template = player_template
		})
		
		
