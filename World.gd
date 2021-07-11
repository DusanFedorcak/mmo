extends Node2D
class_name WorldNode

const CharacterScene = preload("res://Character.tscn")


var player = null


func _ready():
	Globals.world = self	
	EventBus.connect("fx_created", self, "_on_fx_created")


func setup_server():
	EventBus.connect("player_added", self, "_on_player_added")		
	$Map/Navigation.init_navigation($Map/Terrain, $Map/Roads, $Map/Obstacles)
	
	for i in range(10):
		var character = add_character(
			-i, 
			Assets.get_random_name(), 
			Assets.get_random_character_template(),
			$Map/Navigation.get_random_empty_cell(), 
			Assets.get_random_color(),
			false
		)
		character.get_node("AI").enabled = true
		
	
func _on_player_added(id, info):		
	# add existing to the new player
	if id != 1:
		for existing in $Map/Characters.get_children():
			rpc_id(id, "add_character", 
				existing.id, existing.char_name, existing.template, existing.position, existing.color, true
			)	
	
	# add to server
	var character = add_character(
		id, info["name"], info["template"], 
		$Map/Navigation.get_closest_empty_cell(Vector2(500, 300)), 
		Assets.get_random_color(),
		false
	)
	
	# add new one to all clients
	rpc("add_character", 
		id, character.char_name, character.template, character.position, character.color, true
	)	


remote func add_character(char_id, name, template, position, color, is_puppet):
	var character = CharacterScene.instance()	
	character.id = char_id
	character.is_puppet = is_puppet
	character.name = str(char_id)
	character.set_char_name(name)
	character.template = template
	character.color = color
	character.get_node("Shape").frames = Assets.character_sprites[template]
	character.position = position		
	$Map/Characters.add_child(character)	
	if char_id == get_tree().get_network_unique_id():
		player = character		
	return character

	
func _process(delta):
	if Network.is_server:
		var game_state = {}
		#OPTIMIZE SENT STATE TO SCREEN PROXIMITY objects
		for char_node in $Map/Characters.get_children():
			game_state[char_node.id] = char_node.dump_state()
				
		rpc_unreliable("update_game", game_state)
		
	if player:
		$PlayerCamera.position = player.position
		
	$MouseLocation.position = get_global_mouse_position()
		
		
func get_character(char_id):
	return $Map/Characters.get_node_or_null(str(char_id))
	

remote func update_game(game_state):
	for char_id in game_state:
		var char_state = game_state[char_id]
		var character = get_character(char_id)
		if character:						
			character.update_state(game_state[char_id])
			
			
remote func receive_command(command):
	var id = get_tree().get_rpc_sender_id()
	var character = get_character(id)
	if character:
		character.get_node("Controls").receive_command(command)
		
		
func _on_fx_created(fx):
	$Effects.add_child(fx)
	
