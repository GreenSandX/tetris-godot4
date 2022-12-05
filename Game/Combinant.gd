class_name Combinant

signal separate_to(new_combinant_s :Array)

var sequence_s := []
var tile_pos := []	# Block pos and transfrom through the linkjoint
var transform_s := []
var cell_s := []

var BLOCK_STEP = 64
enum { RIGHT, DOWN, LEFT, UP }

func _init(cell_A :Cell, cell_B :Cell, linkjoint_A :Area2D, linkjoint_B :Area2D):
	add(cell_A, cell_B, linkjoint_A , linkjoint_B)
	connect("separate_to", Callable(CombinantMgr, "_on_combinant_separate_to"))
	
	
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
	var cell_tile_pos = new_cell.block_pos_s
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
		"Tile_pos" : cell_tile_pos,
		"Offset" : offset / BLOCK_STEP,
		"Rotation" : rotation,
		"Transted_tile_pos" : transte_pos(cell_tile_pos, rotation, offset)
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
	transform_s.append(base_cell_trs)	# For the first cell's trs
	return base_cell_trs


func transte_pos(pos_s :Array, rotation, offset :Vector2) -> Array :
	var transted_pos = []
	for pos in pos_s :
#		var i = pos.rotated(rotation)
		var i = rotate_orthogonal(pos, rotation)
		i += offset / BLOCK_STEP
		transted_pos.append(i)
	return transted_pos


func find_transform_pos(tile_pos :Vector2) -> Dictionary :
	for transform in transform_s:
#		if !is_instance_valid(transform):
		if transform.Transted_tile_pos.has(tile_pos): 
			return transform
	return {}


func split_tile(tile_pos) :
	var tile_pos_s = []
	if tile_pos is Vector2 : tile_pos_s.append(tile_pos)
	if tile_pos is Array : tile_pos_s = tile_pos
	
	var split_cell_s = []
	var split_pos_s = []
	for pos in tile_pos_s :
		var trs = find_transform_pos(pos)
		if trs != {} :
			var cell = trs.Cell
			if split_cell_s.has(cell) : 
				split_pos_s[split_cell_s.find(cell)].append(
						trs.Tile_pos[trs.Transted_tile_pos.find(pos)])
			else : 
				split_cell_s.append(cell)
				split_pos_s.append([trs.Tile_pos[trs.Transted_tile_pos.find(pos)]])

	if split_cell_s != [] :
		for i in range(split_cell_s.size()) :
			split_cell_s[i].split_block(split_pos_s[i])



func merge(combinant_B :Combinant, cell_A: Cell, cell_B :Cell, 
		linkjoint_A :Area2D, linkjoint_B :Area2D):
			
	sequence_s.append(create_sequence(cell_A, cell_B))

	var new_trs = create_transform(cell_A, cell_B, linkjoint_A, linkjoint_B)
	var new_rotation = new_trs.Rotation
	var new_offset = new_trs.Offset * BLOCK_STEP
	var old_trs = combinant_B.find_transform(cell_B)
	var old_rotation = old_trs.Rotation
	var old_offset = old_trs.Offset * BLOCK_STEP
	var base_trs = find_transform(cell_A)
	var base_rotation = base_trs.Rotation
	var base_offset = base_trs.Offset * BLOCK_STEP
	
	var all_rotation = abs_ort(base_rotation + orthogonal(linkjoint_A.rotation) + LEFT 
			- old_rotation - orthogonal(linkjoint_B.rotation))
	var all_offset = new_offset - rotate_orthogonal(old_offset, all_rotation)
	
	for trs in combinant_B.transform_s :
		trs.Transted_tile_pos = transte_pos(trs.Transted_tile_pos, all_rotation, all_offset)
		trs.Offset = all_offset / BLOCK_STEP + rotate_orthogonal( trs.Offset, all_rotation)
		trs.Rotation = abs_ort( trs.Rotation + all_rotation)
	transform_s.append_array(combinant_B.transform_s)
#	tile_pos.append_array(combinant_B.tile_pos)
	cell_s.append_array(combinant_B.cell_s)
	sequence_s.append_array(combinant_B.sequence_s)


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
#			return


func delete_cell(cell :Cell) -> void :
	if cell_s.has(cell) :
		var remove_index = []
		for i in range(sequence_s.size()) :
			if sequence_s[i].Cell_A == cell || sequence_s[i].Cell_B == cell :
#				sequence_s.remove_at(i)
				remove_index.append(i)
		for i in remove_index :
			sequence_s.remove_at(i)
		remove_cell(cell)


func print_all():
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
		print("|-- ", j, " : ", transform.Cell.get_name(), " ",
		transform.Offset, " [", transform.Rotation, "] -- ",transform.Transted_tile_pos)
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
