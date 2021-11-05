extends Node

signal network_status_changed()
signal connected_players_changed()

const MAX_PLAYERS = 32

var is_connected = false
var is_server = false
var connected_players = {}
var _client_info = null


func switch_signals(do_connect, is_server):
	if is_server:
		if do_connect:
			get_tree().connect("network_peer_connected", self, "_player_connected")
			get_tree().connect("network_peer_disconnected", self, "_player_disconnected")
		else:
			get_tree().disconnect("network_peer_connected", self, "_player_connected")
			get_tree().disconnect("network_peer_disconnected", self, "_player_disconnected")
	else:
		if do_connect:
			get_tree().connect("connected_to_server", self, "_connected_ok")
			get_tree().connect("connection_failed", self, "_connected_fail")
			get_tree().connect("server_disconnected", self, "_server_disconnected")
		else:
			get_tree().disconnect("connected_to_server", self, "_connected_ok")
			get_tree().disconnect("connection_failed", self, "_connected_fail")
			get_tree().disconnect("server_disconnected", self, "_server_disconnected")	
			
			
# --- SERVER FUNCTIONS ---
			

func create_server(port):
	connected_players.clear()	
	Log.info("Creating server at %d ..." % port)	
	switch_signals(true, true)
	
	var peer = NetworkedMultiplayerENet.new()
	peer.create_server(port, MAX_PLAYERS)	
	get_tree().network_peer = peer
	is_server = true
	is_connected = true
	emit_signal("network_status_changed")
	

func disconnect_network():	
	if Network.is_connected:
		switch_signals(false, Network.is_server)						
		
	get_tree().network_peer = null
	is_server = false		
	is_connected = false	
	emit_signal("network_status_changed")
	
	
func _player_connected(id):
	Log.info("Player %d connected." % id)	
	

func _player_disconnected(id):
	Log.info("Player %d disconnected." % id)
	connected_players.erase(id)
	rpc("update_connected_players", connected_players)
	emit_signal("connected_players_changed")
	

master func register_player(info):		
	var network_id = get_tree().get_rpc_sender_id()
	connected_players[network_id] = info	
	Log.info("Registering player %d as %s." % [network_id, info.name])
	rpc("update_connected_players", connected_players)
	emit_signal("connected_players_changed")
	
	
# --- CLIENT FUNCTIONS ---
	
	
func connect_server(player_name, player_template, address, port):
	Log.info("Joining server %s:%d ..." % [address, port])
	switch_signals(true, false)	
	
	_client_info = {
		name = player_name,
		template = player_template		
	}
	
	var peer = NetworkedMultiplayerENet.new()	
	peer.create_client(address, port)	
	get_tree().network_peer = peer	
	

func _connected_ok():	
	Log.info("Connected to server.")
	is_connected = true
	emit_signal("network_status_changed")
	rpc_id(1, "register_player", _client_info)
	

func _server_disconnected():
	switch_signals(false, false)
	is_connected = false		
	Log.info("Disconnected from server.")
	emit_signal("network_status_changed")


func _connected_fail():
	switch_signals(false, false)
	is_connected = false
	
	Log.info("Connection failed.")	
	emit_signal("network_status_changed")

	
puppet func update_connected_players(_connected_players):
	connected_players = _connected_players
	emit_signal("connected_players_changed")
