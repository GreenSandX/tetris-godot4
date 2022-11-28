#class_name BlockCombinant
extends "res://Game/Combinant.gd"

func on_cell_merged(cell_A:Cell, linkjoint_A:Area2D, cell_B:Cell, linkjoint_B:Area2D):
	super(cell_A, linkjoint_A, cell_B, linkjoint_B)


func on_cell_dismerge(cell_A:Cell, linkjoint_A:Area2D, cell_B:Cell, linkjoint_B:Area2D):
	super(cell_A, linkjoint_A, cell_B, linkjoint_B)
