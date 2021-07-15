extends Node2D


var current_item = null


remotesync func equip(item_name):
	#unequip current item first
	if current_item:
		current_item.state = Item.State.IN_INVENTORY
		current_item = null
		
	#equip new item if valid
	if item_name:
		var item = get_node_or_null(item_name)
		if item:			
			current_item = item
			current_item.state = Item.State.EQUIPPED
			
	
remotesync func drop_current(at_point):
	if current_item:	
		var item = current_item
		remove_child(current_item)
		current_item = null
		EventBus.emit_signal("item_dropped", item, at_point)
		

func _ready():
	for item in get_children():
		item.state = Item.State.IN_INVENTORY
