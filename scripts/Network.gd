extends Node


const MAX_PLAYERS = 32


var is_connected = false
var is_server = false
var player_info = {}
var my_info = null


func _player_connected(id):
	Log.info("Player %d connected." % id)	
	

func _player_disconnected(id):
	Log.info("Player %d disconnected." % id)
	player_info.erase(id)


func _connected_ok():	
	Log.info("Connected to server.")
	is_connected = true
	rpc_id(1, "register_player", my_info)	


func _server_disconnected():
	is_connected = false
	Log.info("Disconnected from server.")	


func _connected_fail():	
	Log.info("Connection failed.")	


func create_server(port):		
	Log.info("Creating server at %d ..." % port)
	get_tree().connect("network_peer_connected", self, "_player_connected")
	get_tree().connect("network_peer_disconnected", self, "_player_disconnected")
	
	var peer = NetworkedMultiplayerENet.new()
	peer.create_server(port, MAX_PLAYERS)	
	get_tree().network_peer = peer
	is_server = true
	is_connected = true
		
	
func connect_server(player_name, player_template, address, port):
	Log.info("Joining server %s:%d ..." % [address, port])
	
	my_info = {
		name = player_name,
		template = player_template		
	}
	
	get_tree().connect("connected_to_server", self, "_connected_ok")
	get_tree().connect("connection_failed", self, "_connected_fail")
	get_tree().connect("server_disconnected", self, "_server_disconnected")
	
	var peer = NetworkedMultiplayerENet.new()	
	peer.create_client(address, port)	
	get_tree().network_peer = peer


func disconnect_network():
	is_connected = false
	is_server = false	
	get_tree().network_peer = null	
	

# --- REMOTE FUNCTIONS ---
	

master func register_player(info):		
	var network_id = get_tree().get_rpc_sender_id()
	player_info[network_id] = info
	Log.info("Registering player %d as %s." % [network_id, info])
	EventBus.emit_signal("player_registered", network_id, info)	
