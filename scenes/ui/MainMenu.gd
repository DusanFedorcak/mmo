extends PanelContainer

const MAX_PLAYERS = 32
var player_template = 0

onready var world_node = $"../.."

func _ready():
	$VBox/HBox/PlayerName.text = Assets.get_random_name()
	player_template = randi() % len(Assets.character_sprites)	
	_update_player_template()
	visible = true
	

func _update_player_template():
	$VBox/PlayerSelection/Appearance.texture = (
		Assets.character_sprites[player_template].get_frame("walk_down", 0)
	)
	

func parse_server_address():
	var parsed = $VBox/ServerAddress.text.split(":")
	return { address = parsed[0], port = parsed[1].to_int()}
	

func _on_StartServer_pressed():	
	$VBox/JoinGame.disabled = true
	$VBox/StartServer.disabled = true
	$VBox/Localgame.disabled = true
	visible = false
	Network.create_server(parse_server_address().port)
	world_node.setup_for_server()
		
		
func _on_Localgame_pressed():
	$VBox/JoinGame.disabled = true
	$VBox/StartServer.disabled = true
	$VBox/Localgame.disabled = true
	visible = false

	var server_info = parse_server_address()
	Network.create_server(parse_server_address().port)
	world_node.setup_for_server()
	EventBus.emit_signal("player_registered", 1, { 
		name = $VBox/HBox/PlayerName.text,
		template = player_template
	})


func _on_JoinGame_pressed():		
	$VBox/JoinGame.disabled = true
	$VBox/StartServer.disabled = true
	$VBox/Localgame.disabled = true
	visible = false

	var server_info = parse_server_address()
	Network.connect_server(
		$VBox/HBox/PlayerName.text, player_template, server_info.address, server_info.port
	)
	world_node.setup_for_client()
	world_node.setup_for_client()
		

func _on_Randomize_pressed():
	$VBox/HBox/PlayerName.text = Assets.get_random_name()


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




