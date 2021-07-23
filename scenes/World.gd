extends Node2D
class_name WorldNode	
	

remotesync func load_map(map_name):
	var map = Assets.MAPS[map_name].instance()
	map.name = "Map"
	add_child(map)
	move_child(map, 0)
	
	if Network.is_server:
		map.setup_for_server()
	else:
		map.setup_for_client()
	
	$UI/Splash.visible = false
	$UI/MainMenu.visible = false
	

func delete_current_map():
	var map = get_node_or_null("Map")
	if map:
		remove_child(map)
		map.queue_free()
		
		$UI/Splash.visible = true
		$UI/MainMenu.visible = true
	
