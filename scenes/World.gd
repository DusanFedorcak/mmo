extends Node2D
class_name WorldNode	


func setup_for_server():	
	$Map.setup_for_server()
	

func setup_for_client():
	$Map.setup_for_client()

