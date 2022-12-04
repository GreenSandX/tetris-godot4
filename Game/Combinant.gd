class_name Combinant

var sequence_s := []
var tile_pos := []	# Block pos and transfrom through the linkjoint
var transform_s := []
var cell_s := []

var BLOCK_STEP = 64
enum { RIGHT, DOWN, LEFT, UP }

func _init(cell_A :Cell, cell_B :Cell, linkjoint_A :Area2D, linkjoint_B :Area2D):
	add(cell_A, cell_B, linkjoint_A , linkjoint_B)
	
	
func remove(cell :Cell):
	for sequence in sequence_s :
		if sequence.Cell_A == cell || sequence.Cell_B == cell :
			sequence_s.erase(sequence)
	for transform in transform_s :
		if transform.Cell == cell :
			transform_s.erase(transform)
	cell_s.erase(cell)
	

func create_sequence(cell_A :Cell, cell_B :Cell) -> Dictionary:
	return {
		"Cell_A" : cell_A ,
		"Cell_B" : cell_B
	}


func add_sequence(cell_A :Cell, cell_B :Cell) -> void :
	sequence_s.append(create_sequence(cell_A, cell_B))


func remove_sequence(cell_A :Cell, cell_B :Cell) -> void :
	for sequence in sequence_s :
		if sequence.Cell_A == cell_A && sequence.Cell_B == cell_B :
			sequence_s.erase(sequence)
			updata_cell(cell_A)
			updata_cell(cell_B)


func create_transform(base_cell :Cell, new_cell :Cell, base_lkj :Area2D, new_lkj :Area2D) -> Dictionary:
	var tile_pos = new_cell.block_pos_s
	var base_trs = find_transform(base_cell)
#	var rotation = rotation_normolize(
#				new_linkjoint.rotation - ( base_transform.Rotation + base_linkjoint.rotation))
#	var offset = base_transform.Offset + base_linkjoint.position + rotate_vec2(Vector2(BLOCK_STEP / 2, 0), base_linkjoint.rotation) - ( new_linkjoint.position - rotate_vec2(Vector2(BLOCK_STEP / 2, 0), new_linkjoint.rotation))
	var base_lkj_rotation = orthogonal(base_lkj.rotation)
	var new_lkj_rotation  = orthogonal(new_lkj.rotation)
	var rotation = abs_ort(base_lkj_rotation + base_trs.Rotation + LEFT - new_lkj_rotation)
	
	var base_lkj_position_r = rotate_orthogonal(base_lkj.position, base_trs.Rotation)
	var new_lkj_position_r  = rotate_orthogonal(new_lkj.position, rotation)
	var offset = base_trs.Offset * BLOCK_STEP + base_lkj_position_r - new_lkj_position_r
	
	return {
		"Cell" : new_cell ,
		"Tile_pos" : tile_pos,
		"Offset" : offset / BLOCK_STEP,
		"Rotation" : rotation,
		"Transted_tile_pos" : transte_pos(tile_pos, rotation, offset),
	}

func find_transform(cell :Cell) -> Dictionary:
	for transform in transform_s:
#		if !is_instance_valid(transform):
		if transform.get("Cell") == cell : 
			return transform
	# or
	var base_cell_trs = {
		"Cell" : cell ,
		"Tile_pos" : cell.block_pos_s,
		"Offset" : Vector2.ZERO,
		"Rotation" : RIGHT,
		"Transted_tile_pos" : cell.block_pos_s,
	}
	transform_s.append(base_cell_trs)
	return base_cell_trs


func transte_pos(pos_s :Array, rotation, offset :Vector2) -> Array :
	var transted_pos = []
	for pos in pos_s :
#		var i = pos.rotated(rotation)
		var i = rotate_orthogonal(pos, rotation)
		i += offset / BLOCK_STEP
		transted_pos.append(i)
	return transted_pos


func merge(combinant :Combinant):
	sequence_s.append_array(combinant.sequence_s)
	transform_s.append_array(combinant.transform_s)
	tile_pos.append_array(combinant.tile_pos)
	cell_s.append_array(combinant.cell_s)


func add(cell_A :Cell, cell_B :Cell, linkjoint_A :Area2D, linkjoint_B :Area2D):
	sequence_s.append(create_sequence(cell_A, cell_B))
	transform_s.append(create_transform(cell_A, cell_B, linkjoint_A, linkjoint_B))
	if !cell_s.has(cell_A) : cell_s.append(cell_A)
	if !cell_s.has(cell_B) : cell_s.append(cell_B)


func updata_cell(cell :Cell) -> void:
	for s in sequence_s : if s.Cell_A == cell || s.Cell_B == cell : return
	remove_cell(cell)


func remove_cell(cell :Cell) -> void :
	cell_s.erase(cell)
	for transform in transform_s : 
		if transform.Cell == cell : 
			transform_s.erase(transform)
			return


func delete_cell(cell :Cell) -> void :
	if cell_s.has(cell) :
		for sequence in sequence_s :
			if sequence.Cell_A == cell || sequence.Cell_B == cell :
				sequence_s.erase(sequence)
		remove_cell(cell)


func print():
	var h = 1
	for cell in cell_s :
		print("#-- ", h, " : ", cell.get_name())
		h += 1
	print("| Sequence_s:")
	var i = 1
	for sequence in sequence_s :
		print("|-- ", i, " : ", sequence.Cell_A.get_name(), " -> ",
				sequence.Cell_B.get_name())
		i += 1
	print("| Transform_s:")
	var j = 1
	for transform in transform_s:
		print("|--Cell ", j, " : ", transform.Cell.get_name())
		print("|----Offset   : ", transform.Offset)
		print("|----Rotation : ", transform.Rotation)
		print("|----Transted_tile_s : ", transform.Transted_tile_pos)
		j += 1


func fast_print():
	var h = 1
	print("--->> Cell_s <<---")
	for cell in cell_s :
		print("#-- ", h, " : ", cell.get_name())
		h += 1
		
	print("--->> Sequence_s <<---")
	for sequence in sequence_s :
		print("|-- ", sequence.Cell_A.get_name(), " --> ", sequence.Cell_B.get_name())
		
	print("--->> Transform_s <<---")
	var j = 1
	for transform in transform_s:
		print("|-- ", j, " : ", transform.Cell.get_name()," ",transform.Transted_tile_pos)
	
#		print("|------Offset   : ", transform.Offset)
#		print("|------Rotation : ", transform.Rotation)
#		print("|--Transted_tile_s : ", transform.Transted_tile_pos)
		j += 1
	print()

func size() -> int :
	return tile_pos.size()

#func rotation_normolize(_rotation :float) -> float:
#	var value = 0.2
#	var rotation = rotation_clamp(_rotation)
#	if   abs(rotation - ( PI / 2 )) <= value : return PI / 2
#	elif abs(rotation - ( -PI / 2)) <= value : return -PI / 2
#	elif abs(rotation - PI) <= value : return PI	
#	elif abs(rotation + PI) <= value : return - PI
#	else : return 0.0


func orthogonal(_rotation :float) -> int :
	var value = 0.2
	var rotation = rotation_clamp(_rotation)
	if   abs(rotation - ( PI / 2 )) <= value : return DOWN
	elif abs(rotation - ( -PI / 2)) <= value : return UP
	elif abs(rotation - PI) <= value : return LEFT	
	elif abs(rotation + PI) <= value : return LEFT
	else : return RIGHT


func rotation_clamp(_rotation :float) -> float:
	if _rotation > TAU : return rotation_clamp(_rotation - TAU )
	if _rotation < - TAU : return rotation_clamp(_rotation + TAU )
	else : return _rotation


func rotate_orthogonal(vec2 :Vector2, rotation) -> Vector2 :
	match rotation :
#		PI / 2  : new_vec2 = Vector2(-vec2.y,  vec2.x)
#		-(PI / 2) : new_vec2 = Vector2( vec2.y, -vec2.x)
#		PI, -PI : new_vec2 = Vector2(-vec2.x, -vec2.y)
#	return new_vec2
#		PI / 2  : print("PI / 2")
#		-(PI / 2) : print("-(PI / 2)")
#		PI, -PI : print("PI, -PI")
#	return Vector2.ZERO
		RIGHT	: return vec2
		DOWN	: return Vector2(-vec2.y, vec2.x)
		LEFT	: return Vector2(-vec2.x,-vec2.y)
		UP		: return Vector2( vec2.y,-vec2.x)
	return Vector2.ZERO


func abs_ort(A :int) -> int :
	if A < 0 	: return abs_ort(A + 4)
	elif A > 3	: return abs_ort(A - 4)
	else		: return A
