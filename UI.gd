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

	if world_node.player:

		if Input.is_mouse_button_pressed(BUTTON_LEFT):
			world_node.try_move_player(world_node.get_global_mouse_position())

		var direction = Vector2.ZERO
		var runnning = false

		if Input.is_action_pressed("ui_up"):
			direction += Vector2.UP

		if Input.is_action_pressed("ui_left"):
			direction += Vector2.LEFT

		if Input.is_action_pressed("ui_right"):
			direction += Vector2.RIGHT

		if Input.is_action_pressed("ui_down"):
			direction += Vector2.DOWN

		var running = Input.is_action_pressed("ui_shift")
		world_node.player.set_motion(direction, running)


func _on_StartServer_pressed():
	if not world_node.player:
		world_node.player = world_node.add_character(Vector2(500, 300), $Menu/VBox/HBox/PlayerName.text)
		$Menu/VBox/JoinGame.disabled = true
		$Menu/VBox/StartServer.disabled = true
		$Menu.visible = false
		#Network.create_server($Menu/VBox/HBox/PlayerName.text, parse_server_address().port, MAX_PLAYERS)


func _on_JoinGame_pressed():
	if not world_node.player:
		world_node.player = world_node.add_character(Vector2(500, 300), $Menu/VBox/HBox/PlayerName.text)
		$Menu/VBox/JoinGame.disabled = true
		$Menu/VBox/StartServer.disabled = true
		$Menu.visible = false

		var server_info = parse_server_address()
		#Network.connect_server($Menu/VBox/HBox/PlayerName.text, server_info.address, server_info.port)


func log_message(message):
	$Console/Output.text += "\n" + message


func _on_Randomize_pressed():
	$Menu/VBox/HBox/PlayerName.text = get_random_name()
