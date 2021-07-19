extends Node2D


var current_item = null


func _ready():	
	pass
		
		
func dump_info():
	var result = []	
	for item in get_children():
		result.append(item.dump_info())
	return result
	
	
func setup_from_info(info):
	for item_info in info:
		add_child(Item.create_from_info(item_info))


# --- REMOTE FUNCTIONS ---


remotesync func equip(item_id):
	#unequip current item first
	if current_item:
		current_item.state = Item.State.IN_INVENTORY
		current_item = null
		
	#equip new item if valid
	if item_id:
		var item = get_node_or_null(item_id)		
		if item:			
			current_item = item
			current_item.state = Item.State.EQUIPPED		
			
	
remotesync func drop_current(at_point):	
	if current_item:	
		var item = current_item
		remove_child(current_item)
		current_item = null
		EventBus.emit_signal("item_dropped", item, at_point)
		

remotesync func take(item_id):	
	var item = Globals.world.get_node_or_null("Map/Items/" + str(item_id))
	if item:
		var parent = item.get_parent()
		parent.remove_child(item)
		item.position = Vector2.ZERO
		add_child(item)
		equip(item.name)
	else:
		Log.error("Node not found %s" % str(item_id))
