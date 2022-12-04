class_name Cell
extends RigidBody2D

var is_merging := false

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
