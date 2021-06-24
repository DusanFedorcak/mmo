extends Node2D

const CharacterScene = preload("res://Character.tscn")


var player = null


func setup_server():
	EventBus.connect("player_added", self, "_on_player_added")	
	$Map/Navigation.init_navigation($Map/Terrain, $Map/Roads)
	#$Map/Navigation.update_mesh($Map/TileMap)
	
	
func _on_player_added(id, info):	
	
	# add existing to the new player
	for existing in $Map/Characters.get_children():
		rpc_id(id, "add_character", existing.id, existing.char_name, existing.template, existing.position, true)	
	
	# add to server
	var character = add_character(id, info["name"], info["template"], Vector2(500, 300), false)
	
	# add new one to all clients
	rpc("add_character", id, character.char_name, character.template, character.position, true)	


remote func add_character(char_id, name, template, position, is_puppet):
	var character = CharacterScene.instance()	
	character.id = char_id
	character.is_puppet = is_puppet
	character.name = str(char_id)
	character.set_char_name(name)
	character.template = template
	character.get_node("Shape").frames = Assets.character_sprites[template]
	character.position = position		
	$Map/Characters.add_child(character)	
	if char_id == get_tree().get_network_unique_id():
		player = character
	return character

	
func _process(delta):
	if Network.is_server:
		var game_state = {}
		for char_node in $Map/Characters.get_children():
			game_state[char_node.id] = char_node.dump_state()
			
		rpc_unreliable("update_game", game_state)
		
		
func get_character(char_id):
	return $Map/Characters.get_node_or_null(str(char_id))
	

remote func update_game(game_state):
	for char_id in game_state:
		var char_state = game_state[char_id]
		var character = get_character(char_id)
		if character:						
			character.update_state(game_state[char_id])		
