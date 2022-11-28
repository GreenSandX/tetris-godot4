class_name BlockCell
extends Cell
var _material := preload("res://Shader/color_swap_m.tres").duplicate()


var color := Color("b316d3ff")

var block_pos_s := []

const BLOCK_SETP := 64

#func _init():
#	pass

func _ready():
	set_material(_material)
	get_material().set_local_to_scene(true)
	get_material().set_shader_parameter("color", color)
	audio_player = Util.try_get_child_from("AudioPlayer", self)
	set_gravity_scale(1)
	super()


func linkjoint_connect_to_combinant():
	for linkjoint in Util.try_get_children_from("LinkJoint", self):
		linkjoint.connect("joint_merged", Callable(CombinantMgr, "on_cell_merged"))
		linkjoint.connect("joint_dismerge", Callable(CombinantMgr, "on_cell_dismerge"))


func splice_block(block:BlockCell, tile_pos:Vector2):
	block_pos_s.append(tile_pos)
	super.splice_cell(block, tile_pos * BLOCK_SETP)




func merge_block(target:BlockCell, self_merge_tile_pos:Vector2, target_merge_tile_pos:Vector2):

	super.merge_cell(target, self_merge_tile_pos * BLOCK_SETP, target_merge_tile_pos * BLOCK_SETP)
