extends Control

const MAX_PLAYERS = 32
var player_template = 0

onready var world_node = $"../.."

func _ready():	
	Network.connect("connected_players_changed", self, "_on_players_changed")
	Network.connect("network_status_changed", self, "_on_network_changed")	
	
	Log.register_target(self)
	Log.info("Press F1 for help")	
	
	$ServerInfo.visible = false
	$Menu/VBox/HBox/PlayerName.text = Assets.get_random_name()
	player_template = randi() % len(Assets.character_sprites)	
	_update_player_template()	

	for map in Assets.MAPS:
		$Menu/VBox/HBox3/MapDropDown.add_item(map)
	

func log_message(message):
	$Console/Output.text += "\n" + message
	

func _update_player_template():
	$Menu/VBox/PlayerSelection/Appearance.texture = (
		Assets.character_sprites[player_template].get_frame("walk_down", 0)
	)
	

func _parse_server_address():
	var parsed = $Menu/VBox/HBox2/ServerAddress.text.split(":")
	return { address = parsed[0], port = parsed[1].to_int()}
	

func _update_controls():	
	$Menu/VBox/JoinGame.disabled = Network.is_connected
	$Menu/VBox/StartServer.disabled = Network.is_connected
	$Menu/VBox/Localgame.disabled = Network.is_connected
	$Menu/VBox/PlayerSelection/PreviousChar.disabled = Network.is_connected
	$Menu/VBox/PlayerSelection/NextChar.disabled = Network.is_connected
	$Menu/VBox/PlayerSelection/RandomizeTemplate.disabled = Network.is_connected
	$Menu/VBox/HBox/PlayerName.editable = not Network.is_connected
	$Menu/VBox/HBox2/ServerAddress.editable = not Network.is_connected
	$Menu/VBox/HBox/Randomize.disabled = Network.is_connected
	$Menu/VBox/HBox3/MapDropDown.disabled = Network.is_connected
	
	$ServerInfo.visible = Network.is_connected
	$ServerInfo/VBox/HBox/Disconnect.disabled = not Network.is_connected
	$ServerInfo/VBox/HBox/StartGame.disabled = not Network.is_server
	$ServerInfo/VBox/HBox/ServerIndicator.visible = Network.is_server
	

func _update_players_list():
	$ServerInfo/VBox/PlayersList.clear()
	for network_id in Network.connected_players:
		var player_info = Network.connected_players[network_id]
		var you = "(you) " if network_id == get_tree().get_network_unique_id() else ""
		$ServerInfo/VBox/PlayersList.add_item("%s %s- [%d]" % [player_info.name, you, network_id])
	

func _on_StartServer_pressed():
	$ServerInfo/VBox/PlayersList.clear()	
	Network.create_server(_parse_server_address().port)
	_update_controls()
		
		
func _on_Localgame_pressed():	
	_on_StartServer_pressed()		
	Network.rpc_id(1, "register_player", { 
		name = $Menu/VBox/HBox/PlayerName.text,
		template = player_template
	})


func _on_JoinGame_pressed():
	var server_info = _parse_server_address()
	Network.connect_server(
		$Menu/VBox/HBox/PlayerName.text, player_template, server_info.address, server_info.port
	)
	

func _on_StartGame_pressed():
	get_tree().refuse_new_network_connections = true
	world_node.rpc("load_map", $Menu/VBox/HBox3/MapDropDown.text)
	$ServerInfo/VBox/HBox/StartGame.disabled = true


func _on_Disconnect_pressed():	
	Network.disconnect_network()	


func _on_network_changed():
	if not Network.is_connected:
		world_node.delete_current_map()
	_update_controls()
	

func _on_players_changed():
	_update_players_list()
		

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
	

func _on_Message_text_entered(new_text):
	_on_Send_pressed()


func _on_Send_pressed():	
	if Network.is_connected:
		var network_id = get_tree().get_network_unique_id()
		var name = (
			Network.connected_players[network_id].name
			if network_id in Network.connected_players
			else "server"		
		)
		rpc("send_message", name, $ServerInfo/VBox/HBox2/Message.text)
		$ServerInfo/VBox/HBox2/Message.text = ""
	

remotesync func send_message(name, message):
	Log.custom(name, message)
