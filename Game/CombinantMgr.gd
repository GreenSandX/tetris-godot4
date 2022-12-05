#class_name Combinant
extends Node

# Recive signal 
# linkjoint: merge(cellA, cellB)

# Merge Infomation : CellA -> cellB

var combinant_s := []


#func _process(delta: float) -> void:
#	if Input.is_action_pressed("show_pos"):
#


func on_cell_merged(cell_A:Cell, linkjoint_A:Area2D, cell_B:Cell, linkjoint_B:Area2D):
	# CellA -> CellB
	var combinant_A :Combinant
	var combinant_B :Combinant
	
	if combinant_s != [] :
		for combinant in combinant_s :
			for sequence in combinant.sequence_s :
				if combinant_A == null :
					if cell_A == sequence.Cell_A || cell_A == sequence.Cell_B :
						combinant_A = combinant
				if combinant_B == null :
					if cell_B == sequence.Cell_A || cell_B == sequence.Cell_B :
						combinant_B = combinant
	
		
	
	if combinant_A == null && combinant_B == null :		# Create new Combinant
		combinant_s.append(Combinant.new(cell_A, cell_B, linkjoint_A, linkjoint_B))

	elif combinant_A != null && combinant_B != null :	# Merge exist combinants
		if combinant_A == combinant_B :	# CellA and CellB has already in one combinant
			combinant_A.add_sequence(cell_A, cell_B)	# Just add new sequence and no other info
		else : merge_combinant(combinant_A, combinant_B, cell_A, cell_B, linkjoint_A, linkjoint_B)
	elif combinant_A == null && combinant_B != null :	# Add to exist combinant
		combinant_B.add(cell_B, cell_A, linkjoint_B, linkjoint_A)
	else: 
		combinant_A.add(cell_A, cell_B, linkjoint_A, linkjoint_B)
	
#	for combinant in combinant_s : combinant.fast_print()
#	check()


func on_cell_dismerge(cell_A:Cell, linkjoint_A:Area2D, cell_B:Cell, linkjoint_B:Area2D):
	for combinant in combinant_s :
		if cell_A in combinant.cell_s : combinant.remove_sequence(cell_A, cell_B)
#	print("--------------------------------------- After dis merged ")
#	print(cell_A.get_name(), " --X--> ", cell_B.get_name())
#	print()
	
#	for combinant in combinant_s : combinant.fast_print()


func merge_combinant(combinant_A :Combinant, combinant_B :Combinant, 
		cell_A: Cell, cell_B :Cell, linkjoint_A :Area2D, linkjoint_B :Area2D):
	if combinant_A == combinant_B : return
#	print("[[[[[[[[[[[[[-------------------- merged ----------------------]]]]]]]]]]]]")
	if combinant_A.size() >= combinant_B.size() : 
		combinant_A.merge(combinant_B, cell_A, cell_B, linkjoint_A, linkjoint_B)
		combinant_s.erase(combinant_B)
	else :
		combinant_B.merge(combinant_A, cell_B, cell_A, linkjoint_B, linkjoint_A)
		combinant_s.erase(combinant_A)


func check():
	for combinant in combinant_s :
		var tile_pos = []
		var tile_pos_x = []
		var tile_pos_y = []
		var split_pos_s = []
		for trs in combinant.transform_s :
			tile_pos.append_array(trs.Transted_tile_pos)
			for pos in trs.Transted_tile_pos :
				tile_pos_x.append(pos.x)
				tile_pos_y.append(pos.y)
#		for x in tile_pos_x :
#			if tile_pos_x.count(x) >= 8 :
#				for i in tile_pos_x : if i == x : tile_pos_x.erase(x)
#				var split_pos_s = []
#				for _pos in tile_pos : if _pos.x == x : split_pos_s.append(_pos)
#				combinant.split_tile(split_pos_s)
		for y in tile_pos_y :
			if tile_pos_y.count(y) >= 10 :
				for i in tile_pos_y : if i == y : tile_pos_y.erase(y)
				for _pos in tile_pos : if _pos.y == y : split_pos_s.append(_pos)
		combinant.split_tile(split_pos_s)
				


func remove_1(number, filt):
	return number != filt
		



var direction = [Vector2.RIGHT, Vector2.DOWN, Vector2.LEFT, Vector2.UP]
func dfs(start :Vector2, array :Array, checked :Array) -> Array:
	var return_list = []
	if !checked.has(start) :
		checked.append(start)
		return_list.append(start)
		for dir in direction :
			var new = start + dir
			if array.has(new) && !checked.has(new) : 
				return_list.append_array(dfs(new, array, checked))
	return return_list


func _on_combinant_separate_to(new_combinants :Array):
	pass
