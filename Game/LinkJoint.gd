extends Area2D

@onready var link_light = $Light
@onready var audio_player = $AudioPlayer
@onready var magnet = $Magnet
@onready var magnet_shape = $Magnet/Shape

signal joint_merged(cell_A :Cell, joint_A :Area2D, cell_B :Cell, joint_B :Area2D)
signal joint_dismerge(cell_A :Cell, joint_A :Area2D, cell_B :Cell, joint_B :Area2D)

var link_timer :Timer
var dislink_timer :Timer
var linkjoint_target :Area2D
var magnetic_target :Area2D
var pinjoint :PinJoint2D

var is_mergeing := false


var state :int

const LINK_DELAY := 0.3
const DISLINK_DELAY := 0.4
enum { IDEL, LINKING, MERGED, DISLINKING, POWEROFF, MANUAL, BREAK }
enum { LINK, DISLINK }
const LIGHT_STATE = {}


func _ready() -> void:
	magnet.connect("area_entered", Callable(self, "on_magnet_area_entered"))
	magnet.connect("area_exited", Callable(self, "on_magnet_area_exited"))
	

	pass




func _process(delta: float) -> void:
	queue_redraw()
	if magnetic_target != null && state != MERGED:
		var cell_target = magnetic_target.get_parent()
		var offset = self.global_position - magnetic_target.global_position
		var radius = magnet_shape.get_shape().get_radius()
		line_width = (radius/offset.length()) * 3
		line_width = clamp(line_width, 0, 3)
#		cell_target.apply_impulse( offset.normalized() * 
#				(- sqrt(radius/2 + offset.length()) + 6)
#				* 3 , 
#				magnetic_target.position)
		cell_target.apply_impulse(  offset * 1, magnetic_target.position)
#		cell_target.angular_damp = clamp((1/offset.length()) * 30, 16, 100)
#		cell_target.apply_impulse( offset * value, magnetic_target.position)

var line_width = 1

func _draw():
	if magnetic_target != null && state != MERGED:
		draw_line(Vector2.ZERO, 
#				get_angle_to()
				(magnetic_target.global_position - self.global_position).rotated(-self.global_rotation), 
				Color.LAWN_GREEN, line_width, true)


func set_state(STATE:int):
	state = STATE
	if STATE != IDEL:
		link_light.visible = true
	match STATE:
		IDEL:
			link_light.visible = false
		LINKING:
#			magnet_shape.disabled = true
			set_color(Color.GOLD).set_energy(0.4)
#			magnet.dis
			
#			audio_player.stop()
#			audio_player.set_stream(load("res://Assets/stone4.ogg"))
#			audio_player.play(0)
			
			
		MERGED:
			set_color(Color.GREEN).set_energy(1)
		DISLINKING:
#			magnet_shape.disabled = false
			set_color(Color.BLUE).set_energy(0.8)
		POWEROFF:
			set_color(Color.MAROON).set_energy(0.6)
		MANUAL:
			set_color(Color.MEDIUM_TURQUOISE).set_energy(0.6)
		BREAK:
			set_color(Color.WEB_GRAY).set_energy(0.6)
		
#	print(self, "SWITCH STATE TO ", STATE)


func set_color(color:Color) -> Light2D: 
	link_light.set_color(color)
	return link_light


func start_timing(TIMER):
	var timer = Timer.new()
	add_child(timer)
	timer.set_one_shot(true) 
	timer.start()
	match TIMER:
		LINKING:
			timer.set_wait_time(LINK_DELAY)
			timer.connect("timeout", Callable(self, "on_link_timeout"))
			link_timer = timer
		DISLINKING:
			timer.set_wait_time(LINK_DELAY)
			timer.connect("timeout", Callable(self, "on_dislink_timeout"))
			dislink_timer = timer


func stop_timing(TIMER):
	match TIMER:
		LINKING:
			Util.try_queue_free(link_timer)
		DISLINKING:
			Util.try_queue_free(dislink_timer)

### Receive Signals
	
func _on_area_entered(target :Area2D) -> void:
	if state == DISLINKING:
		set_state(MERGED)
		stop_timing(DISLINKING)
	elif state == IDEL :	# && !is_linkjing Make sure just on side start linking
		set_state(LINKING)
#		target.is_linkjing = true		# and another don't
#		is_linkjing = true				#
		start_timing(LINKING)
		linkjoint_target = target


func _on_area_exited(target :Area2D) -> void:
	if state == LINKING:
		set_state(IDEL)
		stop_timing(LINKING)
		linkjoint_target = null
	elif state == MERGED:
		set_state(DISLINKING)
		start_timing(DISLINKING)


func on_link_timeout() -> void:
	if state == LINKING:
		set_state(MERGED)
		merge(linkjoint_target)
#		audio_player.stop()
#		audio_player.set_stream(load("res://Assets/merge.wav"))
#		audio_player.play(0)


func on_dislink_timeout() -> void:
	if state == DISLINKING:
		set_state(IDEL)
		dismerge()
		

#		audio_player.stop()
#		audio_player.set_stream(load("res://Assets/plop.ogg"))
#		audio_player.play(0)


func merge(target_joint:Node2D):
	if is_mergeing:
		return
	target_joint.is_mergeing = true
	is_mergeing = true
	emit_signal("joint_merged", self.get_parent(), self, linkjoint_target.get_parent(), linkjoint_target)
	var pin = PinJoint2D.new()
	pin.set_name("Pin")
	get_parent().add_child(pin)
	pin.position = self.position
	pin.set_softness(0.01)
	pin.set_exclude_nodes_from_collision(false)
	pin.set_node_a(self.get_parent().get_path())
	pin.set_node_b(target_joint.get_parent().get_path())
	pinjoint = pin
	target_joint.is_mergeing = false
	is_mergeing = false


func dismerge():
	if Util.try_queue_free(pinjoint) :
		emit_signal("joint_dismerge", self.get_parent(), self, linkjoint_target.get_parent(), linkjoint_target)
	linkjoint_target = null
	magnetic_target = null


func on_magnet_area_entered(magnetic:Area2D):
	magnetic_target = magnetic.get_parent()
#	var mag_line = DampedSpringJoint2D.new()
#	mag_line.set_name("MagLine")
#	get_parent().add_child(mag_line)
#	mag_line.position = self.position
#	mag_line.set_damping(10)
#	mag_line.set_stiffness(1)
#	mag_line.set_exclude_nodes_from_collision(false)
#	mag_line.set_node_a(self.get_parent().get_path())
#	mag_line.set_node_b(target_joint.get_parent().get_path())
#	magnetic_line = mag_line


func on_magnet_area_exited(target:Area2D):
	magnetic_target = null
#	Util.try_queue_free(magnetic_line)
#	magnetic_line = null
	
#func _on_area_entered(jointB :Area2D) -> void:
#	print(self, " _on_area_entered ", jointB)
#	if 	is_linked:	# Make sure just one joint start linking when two joints entered each other
#		return
#	elif is_merged:	# It's just back Hah?
#		Util.try_queue_free(dislink_timer) # Stop timing dislink because It's back
#		set_light_state(LIGHT_STATE.NORMAL)
#		return
#	else:
#		start_link_to(jointB)
#		set_light_state(LIGHT_STATE.LINKING)
#
#
#func _on_area_exited(jointB :Area2D) -> void:
#	print(self, " _on_area_exited ", jointB)
#	jointB.is_linked = false
#	self.is_linked = false
#
#	if link_target == null:	# I dont have linked anyone! Maybe connect time is too short
#		Util.try_queue_free(link_timer)	# 
#		set_light_state(LIGHT_STATE.NORMAL)
#		return
#	else:
#		start_dislink()	# Now, It's time to timing to say baybay ~
#		set_light_state(LIGHT_STATE.MERGED_BUT_DISLINK)
#
#func start_link_to(jointB :Area2D):
#	link_target = jointB
#
#	self.is_linked = true
#	jointB.is_linked = true
#
#	var timer = Timer.new()
#	add_child(timer)
#	timer.set_wait_time(LINK_DELAY)
#	timer.set_one_shot(true) 
#	timer.start()
#	timer.connect("timeout", Callable(self, "on_link_timeout"))
#	link_timer = timer
#	print(self, " IS LINKING TO ", link_target)
#
#
#func start_dislink():
#
#	var timer = Timer.new()
#	add_child(timer)
#	timer.set_wait_time(DISLINK_DELAY)
#	timer.set_one_shot(true)
#	timer.start()
#	timer.connect("timeout", Callable(self, "on_dislink_timeout"))
#	dislink_timer = timer
#
#
#func on_link_timeout():
#
#	self.is_linked = false
#	link_target.is_linked = false
#
#	set_light_state(LIGHT_STATE.MERGED)
#	Util.try_queue_free(link_timer)
#
#	if !is_merged:
#		emit_signal("joint_merged", self, link_target)
#		self.is_merged = true
#		link_target.is_merged = true
#
#func on_dislink_timeout():
#
#	self.is_merged = false
#	link_target.is_merged = false
#
#	set_light_state(LIGHT_STATE.NORMAL)
#	Util.try_queue_free(dislink_timer)
#
#	print(self, " DIS LINKED TO ", link_target)
#
#	link_target = null
#	pass

#	print(self, " HAS LINKED TO ", linking_target
#				," AT ", self.position, " AND ", linking_target.position)
#	print("TNE GLOBAL POSITION IS ", self.global_position, " AND ", linking_target.global_position)
