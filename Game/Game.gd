extends Node2D

@onready var selector = $Selector
@onready var rope = $Selector/Rope
@onready var selector_point = $Selector/SelectorPoint
@onready var debug_label = $Control/Panel/DebugLabel
@onready var produce_point = $ProducePoint
@onready var produce_timer = $ProduceTimer

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

var list = []

var selected_node : Node

#var selected_pos : Vector2
var mouse_pos_origin := Vector2.ZERO

var impulse_multiple := 1

var has_drag = false

var defalt_produce_time = 3.0

var index = 1

func _ready() -> void:
	rope.set_node_a(selector_point.get_path())
	produce_timer.start()
	$Control/Panel/AutoProduce/Label.set_text(String.num(defalt_produce_time, 1))
	produce_timer.set_wait_time(defalt_produce_time)
	

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

func produce_cell():
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



func _on_quit_btn_button_up() -> void:
	get_tree().quit()


func _on_product_btn_button_up() -> void:
	produce_cell()


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
#	if CombinantMgr.combinant_s != [] :
#		for combinant in CombinantMgr.combinant_s :
#			combinant.split_tile([
#					Vector2(-5, -1),Vector2(-4, -1),Vector2(-3, -1),Vector2(-2, -1),
#					Vector2(-1, -1),Vector2(0, -1),Vector2(1, -1),Vector2(2, -1)
#			])
	CombinantMgr.check()
	pass
#	var trs_s = combinant.transform_s
#	for trs in trs_s : if trs.Transted_tile_pos.has(Vector2(-5, -1)) : target_block = trs.Cell
#	if target_block != null : target_block.split_block(Vector2(-1, -1))


func _on_produce_timer_timeout() -> void:
	produce_cell()
	CombinantMgr.check()
	

var auto_produce = true
func _on_auto_toggle_btn_button_up() -> void:
	if auto_produce == true :
		auto_produce = false
		produce_timer.set_one_shot(true)
		produce_timer.stop()
		$Control/Panel/AutoProduce/Label2.set_text("[关] 速度：      秒每个")
	else :
		auto_produce = true
		produce_timer.set_one_shot(false)
		produce_timer.start()
		$Control/Panel/AutoProduce/Label2.set_text("[开] 速度：      秒每个")


func _on_auto_produce_value_changed(value: float) -> void:
	$Control/Panel/AutoProduce/Label.set_text(String.num(value, 1))
	produce_timer.set_wait_time(value)
	if value > 1 : $Control/Panel/AutoProduce.set_step(1)
	else : $Control/Panel/AutoProduce.set_step(0.1)


