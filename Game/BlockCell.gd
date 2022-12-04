class_name BlockCell
extends Cell

var _material := preload("res://Shader/color_swap_m.tres")
var block_cell_pre := load("res://Game/BlockCell.tscn")
var _physics_material := preload("res://Materials/BlockCell.tres")

signal divide(new_cells :Array, color)

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
		
	var checked_list = []
	for pos in block_pos_s :
		if !checked_list.has(pos) :
#			emit_signal("divide",dfs(pos, block_pos_s, checked_list), color)
			var blockcell = BlockCell.new(dfs(pos, block_pos_s, checked_list), color)
			get_parent().add_child(blockcell)
			blockcell.position = position
			blockcell.rotation = rotation
			for lkj in Util.try_get_children_from("LinkJoint", blockcell):
				lkj.set_fast_link()
	self.delete_self()


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


func delete_self():
	for combinant in CombinantMgr.combinant_s :
		if combinant.cell_s.has(self) :
			combinant.delete_cell(self)
#			super.queue_free()

	for lkj in Util.try_get_children_from("LinkJoint", self) :
		if lkj.linkjoint_target != null :
			lkj.queue_free()
	queue_free()
