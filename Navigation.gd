extends Node2D
class_name MyNavigation

var a_star: AStar2D = null
var cell_size = null

func _ready():
	pass


func init_navigation(tilemap: TileMap, roads: TileMap):			
	
	var map_dim = tilemap.get_used_rect()
	cell_size = tilemap.cell_size
	
	var access_map = {}
	
	for cell_pos in tilemap.get_used_cells():		
		var cell_index = tilemap.get_cell(cell_pos.x, cell_pos.y)			
		var sub_tile_coords = tilemap.get_cell_autotile_coord(cell_pos.x, cell_pos.y)		
		var nav_poly = tilemap.tile_set.autotile_get_navigation_polygon(cell_index, sub_tile_coords)
		var cell_origin = tilemap.map_to_world(cell_pos)
		if nav_poly:
			access_map[cell_pos] = 2.0
			
	for cell_pos in roads.get_used_cells():
		access_map[cell_pos] = 1.0
			
	a_star = AStar2D.new()
	
	for p in access_map:
		a_star.add_point(_get_point_id(p, map_dim), p * tilemap.cell_size, access_map[p])
		
	for p in access_map:
		_try_connect_points(p, Vector2.LEFT, access_map, a_star, map_dim)
		_try_connect_points(p, Vector2.RIGHT, access_map, a_star, map_dim)
		_try_connect_points(p, Vector2.UP, access_map, a_star, map_dim)
		_try_connect_points(p, Vector2.DOWN, access_map, a_star, map_dim)	
		_try_connect_points(p, Vector2.UP + Vector2.LEFT, access_map, a_star, map_dim)
		_try_connect_points(p, Vector2.UP + Vector2.RIGHT, access_map, a_star, map_dim)
		_try_connect_points(p, Vector2.DOWN + Vector2.LEFT, access_map, a_star, map_dim)
		_try_connect_points(p, Vector2.DOWN + Vector2.RIGHT, access_map, a_star, map_dim)
		
		
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
	
					
			
func _try_connect_points(p: Vector2, dir: Vector2, access_map: Dictionary, a_star: AStar2D, map_dim: Rect2):
	if p + dir in access_map:
		a_star.connect_points(_get_point_id(p, map_dim), _get_point_id(p + dir, map_dim), true)
	

func _get_point_id(point: Vector2, map_dim: Rect2) -> int:
	return int(point.y * map_dim.size.x + point.x)
					
	
	
				
	
