extends Node2D


func _on_HideBox_body_entered(body):
	var my_id = get_tree().get_network_unique_id()	
	if body is Character and body.player_id == my_id:
		visible = false


func _on_HideBox_body_exited(body):
	var my_id = get_tree().get_network_unique_id()	
	if body is Character and body.player_id == my_id:
		visible = true
