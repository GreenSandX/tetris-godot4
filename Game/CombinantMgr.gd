#class_name Combinant
extends Node

# Recive signal 
# linkjoint: merge(cellA, cellB)

# Merge Infomation : CellA -> cellB

var combinant_s := []



func on_cell_merged(cell_A:Cell, linkjoint_A:Area2D, cell_B:Cell, linkjoint_B:Area2D):
	print(cell_A.get_name(), " Merged ", cell_B.get_name())
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
		
	elif combinant_A != null && combinant_B != null :	# Merge exist combinant
		merge_combinant(combinant_A, combinant_A)
	elif combinant_A == null && combinant_B != null :
		combinant_B.add(cell_A, cell_B, linkjoint_A, linkjoint_B)
	else: 
		combinant_A.add(cell_A, cell_B, linkjoint_A, linkjoint_B)
	
	print("Merged result ---------------------------------------")
	for combinant in combinant_s :
		combinant.print()
	
	
	return 
	

func on_cell_dismerge(cell_A:Cell, linkjoint_A:Area2D, cell_B:Cell, linkjoint_B:Area2D):
	for combinant in combinant_s :
		combinant.delete(cell_A)
		combinant.delete(cell_B)
	
	print("After dis merged ---------------------------------------")
	for combinant in combinant_s :
		combinant.print()
		

#func create_combinant(cell_A :Cell, cell_B:Cell) -> Array:
#	var combinant := [ create_sequence(cell_A, cell_B) ]
#	print("Create Combinant")
#	return combinant
#
#func create_sequence(cell_A :Cell, cell_B:Cell) -> Dictionary:
#	var sequence := {
#		"Cell_A" : cell_A,
#		"Cell_B" : cell_B,
##				"LinkJoint_A" : linkjoint_A,
##				"LinkJoint_B" : linkjoint_B
#	}
#	return sequence

func merge_combinant(combinant_A :Combinant, combinant_B :Combinant):
	if combinant_A == combinant_B :
		return
	if combinant_A.size() > combinant_B.size() :
		combinant_A.merge(combinant_B)
	else:
		combinant_B.merge(combinant_A)

