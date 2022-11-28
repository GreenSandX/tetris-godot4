class_name JointTimer
extends Timer

var jointA :Area2D
var jointB :Area2D

func _init(_jointA:Area2D, _jointB:Area2D) -> void:
	jointA = _jointA
	jointB = _jointB
	add_user_signal("joint_timeout")
	connect("timeout",Callable(self, "_on_timeout"))

func _ready() -> void:
	set_wait_time(0.5)
	set_one_shot(true) 
	start()


func target_is(_jointB:Area2D) -> bool:
	return jointB == _jointB


func _on_timeout():
	emit_signal("joint_timeout", jointA, jointB)
