class_name Combinant

var sequence_s := []
var tile_pos := []	# Block pos and transfrom through the linkjoint
var transform_s := []

var BLOCK_STEP = 64

func _init(cell_A :Cell, cell_B :Cell, linkjoint_A :Area2D, linkjoint_B :Area2D):
	add(cell_A, cell_B, linkjoint_A , linkjoint_B)
	
	
func remove(cell :Cell):
	for sequence in sequence_s :
		if sequence.Cell_A == cell || sequence.Cell_B == cell :
			sequence_s.erase(sequence)
	for transform in transform_s :
		if transform.Cell == cell :
			transform_s.erase(transform)
	

func create_sequence(cell_A :Cell, cell_B :Cell) -> Dictionary:
	return {
		"Cell_A" : cell_A ,
		"Cell_B" : cell_B ,
	}
	



func create_transform(base_cell :Cell, new_cell :Cell, base_linkjoint :Area2D, new_linkjoint :Area2D) -> Dictionary:
	var tile_pos = new_cell.block_pos_s
	var base_transform = find_transform(base_cell)
	var rotation = rotation_normolize(
				new_linkjoint.rotation - ( base_transform.Rotation + base_linkjoint.rotation))
	var offset = base_transform.Offset + base_linkjoint.position + rotate_vec2(Vector2(BLOCK_STEP / 2, 0), base_linkjoint.rotation) - ( new_linkjoint.position - rotate_vec2(Vector2(BLOCK_STEP / 2, 0), new_linkjoint.rotation))
	return {
		"Cell" : new_cell ,
		"Tile_pos" : tile_pos,
		"Offset" : offset,
		"Rotation" : rotation,
		"Transted_tile_pos" : transte_pos(tile_pos, rotation, offset),
	}

func find_transform(cell :Cell) -> Dictionary:
	for transform in transform_s:
		if transform.get("Cell") == cell :
			return transform
	var base_cell = {
		"Cell" : cell ,
		"Tile_pos" : cell.block_pos_s,
		"Offset" : Vector2.ZERO,
		"Rotation" : 0.0,
		"Transted_tile_pos" : cell.block_pos_s,
	}
	transform_s.append(base_cell)
	return base_cell


func transte_pos(pos_s :Array, rotation :float, offset :Vector2) -> Array :
	var transted_pos = []
	for pos in pos_s :
		var i = pos.rotated(rotation)
		i += offset / BLOCK_STEP
		transted_pos.append(i)
	return transted_pos


func merge(combinant :Combinant):
	sequence_s.append_array(combinant.sequence_s)
	transform_s.append_array(combinant.transform_s)
	tile_pos.append_array(combinant.tile_pos)
	

func add(cell_A :Cell, cell_B :Cell, linkjoint_A :Area2D, linkjoint_B :Area2D):
	sequence_s.append(create_sequence(cell_A, cell_B))
#	transform_s.append(create_transform()
	transform_s.append(create_transform(cell_A, cell_B, linkjoint_A, linkjoint_B))
	

func delete(cell :Cell) -> bool:
	for sequence in sequence_s :
		if cell == sequence.Cell_A && cell == sequence.Cell_B:
			sequence_s.erase(sequence)
#				tile_pos.erase()
			transform_s.erase(find_transform(cell))
			print("Delete Cell from combinant :", cell)
			return true
	return false


func print():
	print("Combinant :")
	print("|--Sequence_s:")
	var i = 1
	for sequence in sequence_s :
		print("|---- ", i, " : ", sequence.Cell_A.get_name(), " -> ", sequence.Cell_B.get_name())
		i += 1
	print("|--Transform_s:")
	var j = 1
	for transform in transform_s:
		print("|---- ", j, " : ")
		print("|------Cell     : ", transform.Cell.get_name())
		print("|------Offset   : ", transform.Offset)
		print("|------Rotation : ", transform.Rotation)
		print("|------Transted_tile_s : ", transform.Transted_tile_pos)
		j += 1


func rotation_normolize(_rotation :float) -> float:
	var value = 0.2
	var rotation = rotation_clamp(_rotation)
	if abs(rotation - ( PI / 2 )) <= value :
		return PI / 2
	elif abs(rotation - ( - PI / 2)) <= value :
		return - PI / 2
	elif abs(rotation - PI) <= value :
		return PI	
	elif abs(rotation + PI) <= value :
		return - PI
	else : 
		return 0.0

func rotation_clamp(_rotation :float) -> float:
	print("rotation_clamp : ", _rotation)
	if _rotation > TAU :
		return rotation_clamp(_rotation - TAU )
	if _rotation < - TAU :
		return rotation_clamp(_rotation + TAU )
	print("CLAMP RESULT : ", _rotation)
	return _rotation


func rotate_vec2(vec2 :Vector2, rotation :float) -> Vector2 :
	var new_vec2 :Vector2
	match rotation :
		PI / 2  : new_vec2 = Vector2(-vec2.y, vec2.x)
		-PI / 2 : new_vec2 = Vector2(vec2.y, -vec2.x)
		PI, -PI : new_vec2 = Vector2(-vec2.x, -vec2.y)
	return new_vec2
