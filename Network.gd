extends Node


const MAX_PLAYERS = 32


var is_connected = false
var is_server = false
var player_info = {}
var my_info = null


func _ready():
	pass


func _player_connected(id):
	Log.info("Player %d connected." % id)	
	

func _player_disconnected(id):
	Log.info("Player %d disconnected." % id)
	player_info.erase(id)


func _connected_ok():	
	Log.info("Connected to server.")
	is_connected = true
	rpc_id(1, "register_player", my_info)
	pass


func _server_disconnected():
	Log.info("Disconnected from server.")
	pass # Server kicked us; show error and abort.


func _connected_fail():
	Log.info("Connection failed.")
	pass # Could not even connect to server; abort.


remote func register_player(info):		
	var id = get_tree().get_rpc_sender_id()
	player_info[id] = info
	Log.info("Registering player %d as %s." % [id, info])
	EventBus.emit_signal("player_added", id)	


func create_server(port):		
	Log.info("Creating server at %d ..." % port)
	get_tree().connect("network_peer_connected", self, "_player_connected")
	get_tree().connect("network_peer_disconnected", self, "_player_disconnected")
	
	var peer = NetworkedMultiplayerENet.new()
	peer.create_server(port, MAX_PLAYERS)	
	get_tree().network_peer = peer
	is_server = true
	
	
func connect_server(player_name, address, port):
	Log.info("Joining server %s:%d ..." % [address, port])
	
	my_info = player_name
	get_tree().connect("connected_to_server", self, "_connected_ok")
	get_tree().connect("connection_failed", self, "_connected_fail")
	get_tree().connect("server_disconnected", self, "_server_disconnected")
	
	var peer = NetworkedMultiplayerENet.new()	
	peer.create_client(address, port)	
	get_tree().network_peer = peer


func disconnect_network():
	get_tree().network_peer = null
