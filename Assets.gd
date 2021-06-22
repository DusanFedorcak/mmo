extends Node

const CHARACTER_SPRITE_SIZE = 32

var character_sprites = []
var names = null

func _ready():
	randomize()
	var files = get_files("res://assets/characters/", "png")
	files.sort()
	for file in files:
		load_characters_from_texture(file)
	
	
func get_random_name():
	if not names:
		names = _read_names()
	return names[randi() % len(names)]
	

func _read_names():
	var names = []
	var f = File.new()
	f.open("res://assets/names.txt", File.READ)
	while not f.eof_reached():
		names.append(f.get_line())
	return names
	

func load_characters_from_texture(texture_path: String):	
	var texture = load(texture_path)	
	var char_origins = [
		Vector2(0, 0), Vector2(3, 0), Vector2(6, 0), Vector2(9, 0),
		Vector2(0, 4), Vector2(3, 4), Vector2(6, 4)
	]
	
	for origin in char_origins:
		character_sprites.append(_load_character_sprites(texture, origin))

	
func _add_character_animation(_name, origin: Vector2, frames: SpriteFrames, texture: Texture):		
	frames.add_animation(_name)		
	var frame_indices = [1, 0, 1, 2]	
	
	for i in frame_indices:		
		var frame = AtlasTexture.new()
		frame.atlas = texture		
		frame.region = Rect2((origin + Vector2(i, 0)) * 32, Vector2(32, 32))
		frames.add_frame(_name, frame)
	
	
func _load_character_sprites(texture: Texture, origin: Vector2):
	var frames = SpriteFrames.new()
	
	_add_character_animation("walk_down", origin + Vector2(0, 0), frames, texture)
	_add_character_animation("walk_left", origin + Vector2(0, 1), frames, texture)
	_add_character_animation("walk_right", origin + Vector2(0, 2), frames, texture)
	_add_character_animation("walk_up", origin + Vector2(0, 3), frames, texture)
	return frames
	

func get_files(path, extension=""):
	var files = []
	var dir = Directory.new()
	dir.open(path)
	dir.list_dir_begin(true)

	var file = dir.get_next()
	while file != '':
		if file.ends_with(extension):
			files.append(path + file)
		file = dir.get_next()

	return files
