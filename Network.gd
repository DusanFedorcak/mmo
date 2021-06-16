extends Node

const MAX_PLAYERS = 32

func _ready():
	get_tree().connect("network_peer_connected", self, "_player_connected")
	get_tree().connect("network_peer_disconnected", self, "_player_disconnected")
	get_tree().connect("connected_to_server", self, "_connected_ok")
	get_tree().connect("connection_failed", self, "_connected_fail")
	get_tree().connect("server_disconnected", self, "_server_disconnected")


var player_info = {}
var my_info = null

func _player_connected(id):
	# Called on both clients and server when a peer connects. Send my info to it.
	Log.info("Player %d connected." % id)
	rpc_id(id, "register_player", my_info)

func _player_disconnected(id):
	Log.info("Player %d disconnected." % id)
	player_info.erase(id)

func _connected_ok():
	# Only called on clients, not server. Will go unused; not useful here.
	Log.info("Connected server.")
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
	Log.info("Registering player %d as $s." % [id, info])	

func create_server(player_name, port):
	var peer = NetworkedMultiplayerENet.new()
	peer.create_server(port, MAX_PLAYERS)
	get_tree().network_peer = peer
	

func connect_server(player_name, address, port):
	var peer = NetworkedMultiplayerENet.new()
	peer.create_client(address, port)
	get_tree().network_peer = peer


func disconnect_network():
	get_tree().network_peer = null
