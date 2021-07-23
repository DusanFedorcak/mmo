extends Node

const PASTEL_PALETTE = [
	Color("ffadad"),
	Color("ffd6a5"),
	Color("fdffb6"),
	Color("caffbf"),
	Color("9bf6ff"),
	Color("a0c4ff"),
	Color("bdb2ff"),
	Color("ffc6ff"),
]

const CHARACTER_SPRITE_SIZE = 32
const CHARACTER_FILES = [
	"re1_sprites_v1_0_by_doubleleggy_d2gj3yy.png",
	"re2_sprites_v1_1_by_doubleleggy_d2qb57d.png",
	"re3___monster_sprites_v1_0_by_doubleleggy_d2h3lq9.png",
	"re_cv_sprites_v1_0_by_doubleleggy_d2hwj7w.png",
	"re_side_character_sprites_v1_0_by_doubleleggy_d2hz61y.png",
	"visoes_3_sprites_by_doubleleggy_d2l91ct.png",	
]

# there might be a better way how to dynamically register all items
const ITEMS = [
	"Gun", "Rifle", "Potion", "Sword"
]

const MAPS = {
	"test_map": preload("res://scenes/Map.tscn")
}

var item_scenes = {}
var character_sprites = []
var names = null


func _ready():
	randomize()
	for file in CHARACTER_FILES:
		load_characters_from_texture("res://assets/characters/" + file)

	for item in ITEMS:
		item_scenes[item] = load("res://scenes/items/%s.tscn" % item)


func get_random_name():
	if not names:
		names = _read_names()
	return names[randi() % len(names)]
	
	
func get_random_color():
	return PASTEL_PALETTE[randi() % len(PASTEL_PALETTE)]	
	

func get_random_character_template():
	return randi() % len(character_sprites)
	

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
	# WARNING!, this method do not work in the exported game as all resource pathss get changed!
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
