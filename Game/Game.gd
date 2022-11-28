extends Node2D

@onready var selector = $Selector
@onready var rope = $Selector/Rope
@onready var selector_point = $Selector/SelectorPoint

var circle_cell_pre = preload("res://Game/CircleCell.tscn")

var typeList = {
	1:[
			[-2, 0],[-1, 0],[ 0, 0],[ 1, 0]	],	# I

	2:[						[ 0,-1],
			[-2, 0],[-1, 0],[ 0, 0],		],	# L

	3:[		[-2,-1],[-1,-1],[ 0,-1],
							[ 0, 0]			],	# L_flip

	4:[				[-1,-1],
			[-2, 0],[-1, 0],[ 0, 0]			],	# T

	5:[				[-1,-1],[ 0,-1],
							[ 0, 0],[ 1, 0]	],	# N

	6:[						[ 0,-1],[ 1,-1],
					[-1, 0],[ 0, 0]			],	# N_flip

	7:[				[-1,-1],[ 0,-1],
					[-1, 0],[ 0, 0]			]	# O
}

var colorList = {
	1:Color("c0b914ff"),
	2:Color("c02014ff"),
	3:Color("1467c0ff"),
	4:Color("5ec014ff"),
	5:Color("b316d3ff"),
	6:Color("c06d14ff"),
	7:Color("14c090ff")
}


var selected_node : Node

#var selected_pos : Vector2
var mouse_pos_origin := Vector2.ZERO

var impulse_multiple := 1

var has_drag = false

func _ready() -> void:
	rope.set_node_a(selector_point.get_path())
	pass


func _physics_process(delta: float) -> void:
	pass
	

func _process(delta: float) -> void:
	if Input.is_action_pressed("push"):
		selector.position = get_global_mouse_position()

	else : 
		selector.position = Vector2(-100, -100)
		rope.set_node_b("")
		selected_node = null
		has_drag = false

func _on_quit_btn_button_up() -> void:
	get_tree().quit()


func _on_product_btn_button_up() -> void:
	randomize()
	var rand_type = typeList.get(randi() % 7 + 1 )
	var type_pos_s = []
	for i in rand_type:
		type_pos_s.append(Vector2(i[0], i[1]))
	randomize()
	var rand_color = (randi() % 7) + 1
#	var tetris = TetrisCell.new(type_pos_s, colorList.get(rand_color))
#
	var tetris = TetrisCell.new([Vector2(0, 0), Vector2(1, 0)], colorList.get(rand_color))
	tetris.set_name("TetrisCell")
	tetris.position = position + Vector2(480, 400)
	add_child(tetris)

#	var circle_cell = circle_cell_pre.instantiate()
#	circle_cell.position = position + Vector2(256, 300)
#	add_child(circle_cell)


func _on_clear_btn_button_up() -> void:
	var i = 0
	for child in get_children():
		if child is Cell && i < 4:
			i += 1
			child.queue_free()


func _on_selector_body_exited(body: Node2D) -> void:
#	if selected_node is RigidBody2D:
#		var offset = get_global_mouse_position() - mouse_pos_origin
#		selected_node.apply_impulse(offset.normalized() * 50, selector.position)
#		print("PUUUUSH ", selected_node)
#	if body is RigidBody2D:
#		var offset = get_global_mouse_position() - mouse_pos_origin
#		body.apply_impulse(offset * 1, body.position)
	pass




func _on_h_slider_value_changed(value: float) -> void:
	impulse_multiple = $Control/HSlider.get_value()
	$Control/HSlider/Label.set_text(String.num(impulse_multiple as int))


func _on_selector_body_entered(body: Node2D) -> void:
	if has_drag :
		return
	if body is PhysicsBody2D :
		has_drag = true
		selected_node = body
		rope.set_node_b(body.get_path())