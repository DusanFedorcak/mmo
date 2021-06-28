extends Node2D
class_name MapNavigation

var a_star: AStar2D = null
var cell_size = null
var map_dim = null

func _ready():	
	pass


func init_navigation(terrain: TileMap, roads: TileMap, obstacles: TileMap):			
	
	map_dim = terrain.get_used_rect()
	cell_size = terrain.cell_size
	
	var access_map = {}
	
	# collect all terrain tiles from the terrain that has navpoly
	# (mere existence of navpoly means it can be navigated through)
	for cell_pos in terrain.get_used_cells():		
		var cell_index = terrain.get_cell(cell_pos.x, cell_pos.y)			
		var sub_tile_coords = terrain.get_cell_autotile_coord(cell_pos.x, cell_pos.y)		
		var nav_poly = terrain.tile_set.autotile_get_navigation_polygon(cell_index, sub_tile_coords)
		var cell_origin = terrain.map_to_world(cell_pos)
		if nav_poly:
			access_map[cell_pos] = 2.0
	
	# reduce the cost of tiles when a road is on them
	for cell_pos in roads.get_used_cells():
		access_map[cell_pos] = 1.0
	
	# remove all tiles with some obstacle on them
	# first get all accupied cells for all obstacle tile types
	var occupied_cells = []
	for tile_index in obstacles.tile_set.get_tiles_ids():
		occupied_cells.append(get_intersecting_cells(tile_index, cell_size, obstacles.tile_set))
	
	#then, iterate through the map and remove all map cells that are occupied by an obstacle
	for cell_pos in obstacles.get_used_cells():
		var cell_index = obstacles.get_cell(cell_pos.x, cell_pos.y)				
		for c in occupied_cells[cell_index]:
			access_map.erase(cell_pos + c)		
			
						
	a_star = AStar2D.new()
	
	# fill A-star with points
	for p in access_map:
		a_star.add_point(_get_point_id(p, map_dim), p * cell_size, access_map[p])
		
	for p in access_map:
		# connect 4-neighbourhour
		var has_left = _try_connect_points(p, Vector2.LEFT, access_map, a_star, map_dim)
		var has_right = _try_connect_points(p, Vector2.RIGHT, access_map, a_star, map_dim)
		var has_up = _try_connect_points(p, Vector2.UP, access_map, a_star, map_dim)
		var has_down = _try_connect_points(p, Vector2.DOWN, access_map, a_star, map_dim)	
		
		# connect diagonals only if adjecent directions exists
		if has_left and has_up:
			 _try_connect_points(p, Vector2.UP + Vector2.LEFT, access_map, a_star, map_dim)
		if has_right and has_up:
			_try_connect_points(p, Vector2.UP + Vector2.RIGHT, access_map, a_star, map_dim)
		if has_left and has_down:
			_try_connect_points(p, Vector2.DOWN + Vector2.LEFT, access_map, a_star, map_dim)
		if has_right and has_down:
			_try_connect_points(p, Vector2.DOWN + Vector2.RIGHT, access_map, a_star, map_dim)			
		
	_update_nav_map(access_map, cell_size, map_dim.size)
		
		
func get_simple_path(from: Vector2, to: Vector2):
	var from_id = a_star.get_closest_point(from)
	var to_id = a_star.get_closest_point(to)
	var path = a_star.get_point_path(from_id, to_id)
	
	# correction for tile centers and some randomness
	for i in range(len(path)):
		path[i] += cell_size / 2 + Vector2(randf() * 5.0 - 2.5, randf() * 5.0 - 2.5)
	
	#correction for starting point
	if not path.empty():
		path[0] = from	
	
	return path
	

func get_random_empty_cell():		
	var point = a_star.get_points()[randi() % a_star.get_point_count()]
	return a_star.get_point_position(point) + cell_size * 0.5
	
	
func get_closest_empty_cell(position: Vector2):
	var closest_point = a_star.get_closest_point(position)	
	return a_star.get_point_position(closest_point) + cell_size * 0.5
	
	
func get_intersecting_cells(tile_index: int, cell_size: Vector2, tile_set: TileSet):		
	#get tile region in tile space	
	var region = tile_set.tile_get_region(tile_index)	
	region.position = tile_set.tile_get_texture_offset(tile_index) / cell_size
	region.size /= cell_size
	
	#construct all affected cells
	var affected_cells = []	
	for y in range(region.size.y):
		for x in range(region.size.x):
			affected_cells.append(Vector2(x + region.position.x, y + region.position.y))
	
	# for each cell, construct a rectange and collide it with each tile's collision shape
	# mind the boundaries of cells (make cells a bit smaller)
	var colliding_cells = []
	for cell in affected_cells:
		var cell_shape = RectangleShape2D.new()		
		cell_shape.extents = cell_size * 0.49
		var cell_transform = Transform2D(0, (cell + Vector2(0.5, 0.5)) * cell_size)
		var shape_transform = Transform2D(0, tile_set.tile_get_texture_offset(tile_index))
		for i in tile_set.tile_get_shape_count(tile_index):						
			if tile_set.tile_get_shape(tile_index, i).collide(shape_transform, cell_shape, cell_transform):
				colliding_cells.append(cell)
			
	return colliding_cells
	
					
			
func _try_connect_points(p: Vector2, dir: Vector2, access_map: Dictionary, a_star: AStar2D, map_dim: Rect2):
	if p + dir in access_map:
		a_star.connect_points(_get_point_id(p, map_dim), _get_point_id(p + dir, map_dim), true)
		return true
	else:
		return false
	

func _get_point_id(point: Vector2, map_dim: Rect2) -> int:
	return int((point.y - map_dim.position.y) * map_dim.size.x + point.x - map_dim.position.x)
					
					
func _update_nav_map(map: Dictionary, cell_size: Vector2, map_dim: Vector2):
	for y in range(map_dim.y):
		for x in range(map_dim.x):
			var point = Vector2(x, y)
			
			if not point in map:
				var rect = Polygon2D.new()
				rect.polygon = PoolVector2Array([
					point * cell_size, 
					(point + Vector2.RIGHT) * cell_size, 
					(point + Vector2(1, 1)) * cell_size,
					(point + Vector2.DOWN) * cell_size
				])
				$NavMap.add_child(rect)
		

func _unhandled_key_input(event):
	if Input.is_action_just_pressed("ui_nav_map"):
		$NavMap.visible = not $NavMap.visible
	
	
				
	
