class_name Cell
extends RigidBody2D



#var linkjoint_pos_s := [] #.set_typed(TYPE_VECTOR2)
#var linkjoint_s := []
#var merged_cells := []
#var pinjoint_s := []
#var mergejoint_s := []
var is_merging := false

#var merged_cell_dic = {}
var audio_player :AudioStreamPlayer

func _ready():
	linear_damp = 4
	angular_damp = 15
	set_gravity_scale(2)
	custom_integrator = true
	
	linkjoint_connect_to_combinant()


func linkjoint_connect_to_combinant():
	for linkjoint in Util.try_get_children_from("LinkJoint", self):
		linkjoint.connect("joint_merged", Callable(CombinantMgr, "on_cell_merged"))
		linkjoint.connect("joint_dismerged", Callable(CombinantMgr, "on_cell_dismerged"))
#		linkjoint.connect("joint_merged","on_cell_merged")



func _integrate_forces(state: PhysicsDirectBodyState2D) -> void:
	state.integrate_forces()
	pass


func splice_cell(cell :Node, offset :Vector2):
	Util.move_children_from_to("Shape", cell, self, offset)
	Util.move_children_from_to("VisualNode", cell, self, offset)
	Util.move_children_from_to_check_pos("LinkJoint", cell, self, offset, false)
	cell.queue_free()


func split_cell(cell :Node, offset :Vector2):
	Util.move_children_from_to_check_pos("Shape", cell, self, offset, false)
	Util.move_children_from_to_check_pos("VisualNode", cell, self, offset, false)
	Util.move_children_from_to_check_pos("LinkJoint", cell, self, offset, false)
	cell.queue_free()


func merge_cell(target:Cell, self_merge_pos:Vector2, target_merge_pos:Vector2):
	pass
	
#	target.get_parent().remove_child(target)
#	if !merged_cells.has(target):

#	var pin = PinJoint2D.new()
#	pin.set_name("Pin")
#	add_child(pin)
#	pin.position = self_merge_pos
#	pin.set_softness(0.06)
#	pin.set_exclude_nodes_from_collision(false)
#	pin.set_node_a(self.get_path())
#	pin.set_node_b(target.get_path())
#	pinjoint_s.append(pin)
#	merged_cells.append(target)
#
#	var mergejoint = PinJoint2D.new()
#	mergejoint.set_name("MergeJoint")
#	add_child(mergejoint)
#	mergejoint.position = self_merge_pos
#	target.get_parent().remove_child(target)
#	mergejoint.add_child(target)
#	var target_info = {
#			"MergeJoint" : mergejoint,
#			"Rigidbody" : target,
#			"Shapes" : Util.move_children_from_to("Shape", target, self, self_merge_pos - target_merge_pos)}
#	merged_cells.append(target_info)
#	target.position = - target_merge_pos
#	target.set_freeze_enabled(true)

	
#	print("MergeJoint", mergejoint.position, " Merged ", target)
#	print("", self  , " Freezed ", is_freeze_enabled())
#	print("", target, " Freezed ", target.is_freeze_enabled())
#	print("ADD PIN AT ", pin.position, " FROM ", self ," TO ", target)
#	print(target, " IS MERGING TO ", self)
#	pin.position = self_merge_pos
#	pin.add_child(target)
#	target.position = -target_merge_pos


func dismerge_cell(pos:Vector2):
	pass
#	for merge_info in merged_cells:
#		if merge_info.MergeJoint.position == pos:
#			var cell = merge_info.Rigidbody
#			var mergejoint = merge_info.MergeJoint
#			mergejoint.remove_child(cell)
#			get_parent().add_child(cell)
#			if cell != null:
#				cell.set_freeze_enabled(false)
#			for shape in merge_info.Shapes:
#				self.remove_child(shape)
#				cell.add_child(shape)
#				shape.position = shape.position - pos
#
##				Util.move_children_from_to("Shape", , self, cell , pos)
#			print("MergeJoint ", mergejoint.position, " DISMerged ", cell)
#			mergejoint.queue_free()
#			mergejoint_s.erase(mergejoint)
