extends Node2D

const ClientCharacterScene = preload("res://ClientCharacter.tscn")
const ServerCharacterScene = preload("res://ServerCharacter.tscn")


var player = null


func setup_server():
	EventBus.connect("player_added", self, "_on_player_added")
	
	
func _on_player_added(id):
	_add_server_character(id, Network.player_info[id], Vector2(500, 300))


func _add_client_character(char_id, name, position):
	var new_character = ClientCharacterScene.instance()	
	new_character.name = str(char_id)
	new_character.set_char_name(name)
	new_character.position = position	
	$Map/Characters.add_child(new_character)
	return new_character
	
	
func _add_server_character(char_id, name, position):
	var new_character = ServerCharacterScene.instance()	
	new_character.name = str(char_id)
	new_character.set_char_name(name)
	new_character.position = position	
	$Map/Characters.add_child(new_character)
	player = new_character
	return new_character


func try_move_player(new_position):
	player.path = $Map/Navigation.get_simple_path(player.position, new_position, false)
	
	
func _process(delta):
	if Network.is_server:
		var game_state = {}
		for char_node in $Map/Characters.get_children():
			game_state[char_node.name] = char_node.dump_state()
			
		rpc_unreliable("update_game", game_state)	
		

remote func update_game(game_state):
	for char_id in game_state:
		var char_state = game_state[char_id]
		var char_node = $Map/Characters.get_node_or_null(str(char_id))
		if not char_node:			
			char_node = _add_client_character(char_id, char_state.name, char_state.position)
		char_node.update_state(game_state[char_id])		
