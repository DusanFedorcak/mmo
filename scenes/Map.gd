extends YSort

var HitFXScene = preload("res://scenes/effects/HitFX.tscn")
const CharacterScene = preload("res://scenes/characters/Character.tscn")

signal hit(gun, from_direction, at_point)


func _ready():
	connect("hit", self, "_on_hit")
	EventBus.connect("item_dropped", self, "_on_item_dropped")
	EventBus.connect("fx_created", self, "_on_fx_created")
	

func setup_for_server():
	EventBus.connect("player_registered", self, "_on_player_registered")
	$Navigation.init_navigation($Terrain, $Roads, $Obstacles)
	
	for i in range(10):
		spawn_npc()
		

func setup_for_client():
	for i in $Items.get_children():
		i.queue_free()	


func spawn_npc():
	var npc_info = {
		char_name = Assets.get_random_name(), 
		template = Assets.get_random_character_template(),
		position = $Navigation.get_random_reachable_cell(), 
		color = Assets.get_random_color(),						
	}
	# the followig two calls cannot be merge into one `remotesync` call 
	# as the first call handles unique ID creation
	
	# add to server
	var npc = add_character(npc_info)
	npc.get_node("AI").enabled = true		
	# add to all clients
	rpc("add_character", npc.dump_info())
	

func spawn_player(network_id, player_info):	
	var new_player_char_info = {
		char_name = player_info.name, 
		template = player_info.template, 
		position = $Navigation.get_random_reachable_cell(), 
		color = Assets.get_random_color(),		
		player_id = network_id
	}
	# the followig two calls cannot be merge into one `remotesync` call 
	# as the first call handles unique ID creation
	
	# add to server
	var new_player_char = add_character(new_player_char_info)
	# add new one to all clients 
	rpc("add_character", new_player_char.dump_info())	
		
func send_state_update():	
	var game_state = {}
	#OPTIMIZE SENT STATE TO SCREEN PROXIMITY objects
	for char_node in $Characters.get_children():
		game_state[char_node.id] = char_node.dump_state()
			
	rpc_unreliable("update_state", game_state)


func _on_player_registered(network_id, player_info):		
	# add all existing characters to the new player's map
	if network_id != 1:
		for existing in $Characters.get_children():
			rpc_id(network_id, "add_character", existing.dump_info())				
				
	spawn_player(network_id, player_info)	


func _on_hit(gun, from_direction, at_point):
	rpc("create_hit_effect", at_point)
	
	
func _on_fx_created(fx):
	$Effects.add_child(fx)
	

func _on_item_dropped(item, at_point):
	item.position = at_point
	item.state = Item.State.DROPPED
	$Items.add_child(item)
	
	
func _get_character(char_id):
	return $Characters.get_node_or_null(str(char_id))
	

# --- REMOTE FUNCTIONS ---		

			
remote func add_character(character_info):	
	var character = CharacterScene.instance()		
	character.setup_from_info(character_info)	
	$Characters.add_child(character)
	
	if character.player_id == get_tree().get_network_unique_id():
		Globals.world.player = character		
		
	return character
	
	
remote func add_item():
	pass

puppet func update_state(game_state):
	for char_id in game_state:
		var char_state = game_state[char_id]
		var character = _get_character(char_id)
		if character:						
			character.update_state(game_state[char_id])	
			
	
remotesync func create_hit_effect(at_point):	
	var hit_fx = HitFXScene.instance()
	hit_fx.position = at_point
	hit_fx.modulate = Color.cornsilk
	EventBus.emit_signal("fx_created", hit_fx)
	

	
