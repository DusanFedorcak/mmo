extends CanvasLayer


onready var world_node = $".."
var is_server = false
var names = null

const MAX_PLAYERS = 32


func _read_names():
	var names = []
	var f = File.new()
	f.open("res://assets/names.txt", File.READ)
	while not f.eof_reached():
		names.append(f.get_line())
	return names


func get_random_name():
	if not names:
		names = _read_names()
	return names[randi() % len(names)]


func _ready():
	randomize()
	Log.register_target(self)
	$Menu/VBox/HBox/PlayerName.text = get_random_name()


func parse_server_address():
	var parsed = $Menu/VBox/ServerAddress.text.split(":")
	return { address = parsed[0], port = parsed[1].to_int()}


func _on_Exit_pressed():
	get_tree().quit()


func _unhandled_input(_event):
	if Input.is_action_just_pressed("ui_cancel"):
		$Menu.visible = not $Menu.visible

	if Network.is_connected:
		if Input.is_mouse_button_pressed(BUTTON_LEFT):
			rpc_id(1, "receive_command", {
					name = "MOVE",
					position = world_node.get_global_mouse_position()
				}
			)	
			

remote func receive_command(command):
	var id = get_tree().get_rpc_sender_id()
	var player = world_node.get_character(id)
	if player:
		player.get_node("AI").receive_command(command)


func _on_StartServer_pressed():
	if not world_node.player:		
		$Menu/VBox/JoinGame.disabled = true
		$Menu/VBox/StartServer.disabled = true
		$Menu.visible = false
		Network.create_server(parse_server_address().port)
		world_node.setup_server()


func _on_JoinGame_pressed():
	if not world_node.player:		
		$Menu/VBox/JoinGame.disabled = true
		$Menu/VBox/StartServer.disabled = true
		$Menu.visible = false

		var server_info = parse_server_address()
		Network.connect_server($Menu/VBox/HBox/PlayerName.text, server_info.address, server_info.port)


func log_message(message):
	$Console/Output.text += "\n" + message


func _on_Randomize_pressed():
	$Menu/VBox/HBox/PlayerName.text = get_random_name()
