class_name BlockCell
extends Cell

var _material := preload("res://Shader/color_swap_m.tres")
var block_cell_pre := load("res://Game/BlockCell.tscn")
var _physics_material := preload("res://Materials/BlockCell.tres")

var color := Color("b316d3ff")

var block_pos_s := []

const BLOCK_SETP := 64

func _init(_pos = null ,_color = Color.GREEN):
	if _pos == null		: pass
	if _pos is Vector2 	: block_pos_s.append(_pos)
	if _pos is Array 	: block_pos_s = _pos
	color = _color


func _ready():
	for pos in block_pos_s : splice_block(pos)
	
	set_material(_material.duplicate())
	get_material().set_local_to_scene(true)
	get_material().set_shader_parameter("color", color)
	audio_player = Util.try_get_child_from("AudioPlayer", self)
#	set_gravity_scale(1)
	
	set_physics_material_override(_physics_material)
	super()


func linkjoint_connect_to_combinant():
	for linkjoint in Util.try_get_children_from("LinkJoint", self):
		linkjoint.connect("joint_merged", Callable(CombinantMgr, "on_cell_merged"))
		linkjoint.connect("joint_dismerge", Callable(CombinantMgr, "on_cell_dismerge"))


func splice_block(tile_pos :Vector2):
	if !block_pos_s.has(tile_pos) :
		block_pos_s.append(tile_pos)
	super.splice_cell(block_cell_pre.instantiate(), tile_pos * BLOCK_SETP)


func split_block(tile_pos :Vector2):
	if block_pos_s.has(tile_pos) :
		super.split_cell(block_cell_pre.instantiate(), tile_pos * BLOCK_SETP)
		block_pos_s.erase(tile_pos)
		
		

func divide(divide_block_pos_s :Array):
	var new_blockcell = BlockCell.new()
	for pos in divide_block_pos_s : splice_block(pos)
