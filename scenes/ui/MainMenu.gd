extends Control

const MAX_PLAYERS = 32
var player_template = 0

onready var world_node = $"../.."

func _ready():
	Log.register_target(self)
	Log.info("Press F1 for help")	
	$Menu/VBox/HBox/PlayerName.text = Assets.get_random_name()
	player_template = randi() % len(Assets.character_sprites)	
	_update_player_template()	
	
	$ServerInfo/VBox/List.add_item("Test Item1")
	$ServerInfo/VBox/List.add_item("Test Item2")
	

func log_message(message):
	$Console/Output.text += "\n" + message
	

func _update_player_template():
	$Menu/VBox/PlayerSelection/Appearance.texture = (
		Assets.character_sprites[player_template].get_frame("walk_down", 0)
	)
	

func parse_server_address():
	var parsed = $Menu/VBox/ServerAddress.text.split(":")
	return { address = parsed[0], port = parsed[1].to_int()}
	

func switch_menu(state):
	$Menu/VBox/JoinGame.disabled = not state
	$Menu/VBox/StartServer.disabled = not state
	$Menu/VBox/Localgame.disabled = not state
	visible = state	


func _on_StartServer_pressed():	
	switch_menu(false)
	Network.create_server(parse_server_address().port)
	world_node.setup_for_server()
		
		
func _on_Localgame_pressed():
	switch_menu(false)

	var server_info = parse_server_address()
	Network.create_server(parse_server_address().port)
	world_node.setup_for_server()
	EventBus.emit_signal("player_registered", 1, { 
		name = $Menu/VBox/HBox/PlayerName.text,
		template = player_template
	})


func _on_JoinGame_pressed():		
	switch_menu(false)

	var server_info = parse_server_address()
	Network.connect_server(
		$Menu/VBox/HBox/PlayerName.text, player_template, server_info.address, server_info.port
	)
	world_node.setup_for_client()	
		

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


func _on_Exit_pressed():
	get_tree().quit()
	
	
func _on_Disconnect_pressed():
	Network.disconnect_network()
