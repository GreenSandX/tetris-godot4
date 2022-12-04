extends Node2D

@onready var selector = $Selector
@onready var rope = $Selector/Rope
@onready var selector_point = $Selector/SelectorPoint
@onready var debug_label = $Control/Panel/DebugLabel
@onready var produce_point = $ProducePoint

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

var list = [6, 5, 3, 6]

var selected_node : Node

#var selected_pos : Vector2
var mouse_pos_origin := Vector2.ZERO

var impulse_multiple := 1

var has_drag = false

func _ready() -> void:
	rope.set_node_a(selector_point.get_path())


func _process(_delta: float) -> void:
	if Input.is_action_pressed("push"):
		selector.position = get_global_mouse_position()
	else : 
		selector.position = Vector2(-100, -100)
		rope.set_node_b("")
		selected_node = null
		has_drag = false
	
#
#func _on_block_cell_divide(pos_s :Array, color):
#	var tetris = BlockCell.new(pos_s, color)
#


func _on_quit_btn_button_up() -> void:
	get_tree().quit()


var index = 1
func _on_product_btn_button_up() -> void:
	var type_pos_s = []
	var rand_type
	if list.is_empty() :
		randomize()
		rand_type = typeList.get(randi() % 7 + 1 )
	else : 
		rand_type = typeList.get(list.pop_front())
	for i in rand_type:
		type_pos_s.append(Vector2(i[0], i[1]))
	randomize()
	var rand_color = (randi() % 7) + 1

	var tetris = BlockCell.new(type_pos_s, colorList.get(rand_color))
	tetris.set_name("TetrisCell_" + String.num_int64(index))
	index += 1
	tetris.position = produce_point.position
	add_child(tetris)


func _on_clear_btn_button_up() -> void:
	var i = 0
	for child in get_children():
		if child is Cell && i < 4:
			i += 1
			child.queue_free()



func _on_h_slider_value_changed(_value: float) -> void:
	impulse_multiple = int(_value)
	$Control/HSlider/Label.set_text(String.num(impulse_multiple as int))


func _on_selector_body_entered(body: Node2D) -> void:
	if has_drag :
		return
	if body is PhysicsBody2D :
		has_drag = true
		selected_node = body
		rope.set_node_b(body.get_path())


func _on_print_btn_button_up() -> void:
	var i = 1
	for combinant in CombinantMgr.combinant_s :
		print("----- Combinant [ ",i,  " ] ----- START ------- [ ", i, " ] ")
		combinant.print_all()
		print("----- Combinant [ ",i,  " ] ----- END --------- [ ", i, " ] ")
		i += 1


func _on_util_btn_button_up() -> void:
	var target_block :BlockCell
	var combinant = CombinantMgr.combinant_s[0]
	var trs_s = combinant.transform_s
	for trs in trs_s : if trs.Transted_tile_pos.has(Vector2(-5, -1)) : target_block = trs.Cell
	if target_block != null : target_block.split_block(Vector2(-1, -1))
