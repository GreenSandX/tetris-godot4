class_name Util
extends Node

static func try_get_child_from(_name: String, node: Node) -> Node:
	var child = node.find_child(_name)
	if child != null:
		return child
	return null


static func try_get_children_from(_name: String, node: Node, type: String = "") -> Array:
	var children = []
	children.append_array(node.find_children("*" + _name + "*", type))
#	children.append(node.find_child(name))
	if children.is_empty():
		return []
	return children


#func try_get_child_shape_from(_name:String, node:Node) -> Shape2D:
#	var child = try_get_child_from(_name, node)
#	if child != null:
#		return child.get_shape()
#	return null


static func try_get_children_pos_from(_name: String, node: Node) -> Array:
	var children_pos_s = []
	for child in try_get_children_from(_name, node):
		children_pos_s.append(child.position)
	return children_pos_s


# --- With the SAME POSITION
static func move_child_from_to(child: Node, new: Node, offset: Vector2) -> Node:
	child.position += offset
	child.get_parent().remove_child(child)
	new.add_child(child)
	return child


static func move_children_from_to(_name:String, old:Node, new:Node, offset:Vector2) -> Array:
	var children := []
	for child in try_get_children_from(_name, old):
		children.append(move_child_from_to(child, new, offset))
	return children

# --- With the DIFFERENT POSITION
static func move_child_from_to_global():
	pass


static func move_child_from_to_check_pos(child:Node, _name:String, new:Node, offset:Vector2, check_pos_s:Array, keep_own:bool):# -> Node:
	var new_pos = child.position + offset
	if !check_pos_s.has(new_pos):	# No same position, could move
		move_child_from_to(child, new, offset)
#		return child
	else:	# Have similar position
		if keep_own:# Keep own child and dont move
			pass	
		else:		# Delete own child and dont move
			for own_child in try_get_children_from(_name, new):	# Find the own_child which has the same pos
				if own_child.position == new_pos:
					own_child.queue_free()
#		return null



static func move_children_from_to_check_pos(_name:String, old:Node, new:Node, offset:Vector2, keep_own:bool) -> Array:
	var moved_children = []
	var check_pos_s = try_get_children_pos_from(_name, new)
	for child in try_get_children_from(_name, old):
		moved_children.append(move_child_from_to_check_pos(child, _name, new, offset, check_pos_s, keep_own))
	return sort_out(moved_children)



#static func link_script_to_node(path:String, node:Node):
#	node.set_script()


static func sort_out(array:Array) -> Array:
	var new_array = []
	for element in array:
		if element != null:
			new_array.append(element)
	return new_array
			

static func try_queue_free(node) -> bool:
	if node != null:
		node.queue_free()
		return true
	return false


#static func divide(vec2_array :Array) ->  
