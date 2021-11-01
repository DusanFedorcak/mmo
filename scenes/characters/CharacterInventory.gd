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


func use_current_item():
	if current_item:		
		if current_item.use(get_parent()):
			rpc("consume_current_item")		
		

func _update_top_panel():
	if $"../UI/TopPanel".visible:
		for slot in $"../UI/TopPanel/VBox/Inventory".get_children():
			slot.get_node("TextureRect").texture = null			
		for i in get_child_count():
			var item = get_child(i)
			var item_slot = $"../UI/TopPanel/VBox/Inventory".get_child(i)
			item_slot.get_node("TextureRect").texture = item.get_node("EquipIcon").texture


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
			
	
remotesync func drop_current_item(at_point):	
	if current_item:	
		var item = current_item
		remove_child(current_item)
		current_item = null
		EventBus.emit_signal("item_dropped", item, at_point)
		_update_top_panel()		
		

remotesync func drop_item(item_id, at_point):
	var item = get_node_or_null(str(item_id))
	remove_child(item)		
	EventBus.emit_signal("item_dropped", item, at_point)
	_update_top_panel()		
		

remotesync func consume_current_item():
	var item = current_item
	remove_child(current_item)
	current_item = null	
	_update_top_panel()
		

remotesync func pick_up(item_id):	
	var item = get_node_or_null("/root/World/Map/Items/" + str(item_id))
	if item:
		var parent = item.get_parent()
		parent.remove_child(item)
		item.position = Vector2.ZERO
		item.state = Item.State.IN_INVENTORY
		add_child(item)		
		_update_top_panel()
	else:
		Log.error("Node not found %s" % str(item_id))
