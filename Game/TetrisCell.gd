class_name TetrisCell
extends BlockCell

var block_cell_pre = preload("res://Game/BlockCell.tscn")




func _init(pos_s:Array, _color:Color):
	self.color = _color
	for pos in pos_s:
		splice_block(block_cell_pre.instantiate(), pos)
	super()


func _ready() -> void:
	super()

func merge_tetris(target:TetrisCell, self_pos:Vector2):
	pass
