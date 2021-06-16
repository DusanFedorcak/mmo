extends Node2D

const CharacterScene = preload("res://Character.tscn")

var player = null

func add_character(position, name):
	var new_character = CharacterScene.instance()
	new_character.position = position
	new_character.set_char_name(name)
	$Map/Characters.add_child(new_character)
	return new_character


func try_move_player(new_position):
	player.path = $Map/Navigation.get_simple_path(player.position, new_position, false)
