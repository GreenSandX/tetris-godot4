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
	set_gravity_scale(0)
	custom_integrator = true
	
	linkjoint_connect_to_combinant()
#	for joint in Util.try_get_children_from("LinkJoint", self):
#		joint.connect("joint_merged", Callable(self, "on_joint_merged"))
#		joint.connect("joint_dismerge", Callable(self, "on_joint_dismerge"))
#	for i in Util.try_get_children_from("LinkJoint", self):
#		linkjoint_s.append(i)
#	linkjoint_s = Util.try_get_children_from("LinkJoint", self)
#	linkjoint_pos_s = Util.try_get_children_pos_from("LinkJoint", self)

func linkjoint_connect_to_combinant():
	for linkjoint in Util.try_get_children_from("LinkJoint", self):
		linkjoint.connect("joint_merged", Callable(CombinantMgr, "on_cell_merged"))
		linkjoint.connect("joint_dismerged", Callable(CombinantMgr, "on_cell_dismerged"))




func _integrate_forces(state: PhysicsDirectBodyState2D) -> void:
	state.integrate_forces()
	pass
	

#func connect_linkjoint(linkjoint:Area2D):
#	linkjoint.connect("area_entered", Callable(self, "linkjoint_entered"))

	
#
#func on_joint_merged(jointA:Area2D, jointB:Area2D):
#	if is_merging:
#		return
#	is_merging = true
#	jointB.get_parent().is_merging = true
#	merge_cell(jointB.get_parent(), jointA.position, jointB.position)
#	is_merging = false


#func on_joint_dismerge(jointA:Area2D, jointB:Area2D):
#	dismerge_cell(jointA.position)

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


func splice_cell(cell :Node, offset :Vector2):
	Util.move_children_from_to("Shape", cell, self, offset)
	Util.move_children_from_to("VisualNode", cell, self, offset)
	Util.move_children_from_to_check_pos("LinkJoint", cell, self, offset, false)
	cell.queue_free()
	
	
#	for new_joint in Util.move_children_from_to_check_pos("LinkJoint", cell, self, offset, false):
##		new_joint.set_script("res://Game/LinkJoint.gd")
##		Util.move_child_from_to(new_joint, self, Vector2.ZERO)
##		new_joint.queue_free()
##		new_joint.connect("joint_merged", Callable(self, "on_joint_merged"))
##		new_joint.connect("joint_dismerge", Callable(self, "on_joint_dismerge"))
#		linkjoint_s.append(new_joint)
#		new_joint.call("")
#	print(self, " spliced : ", cell, " at ", offset)

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
