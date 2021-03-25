extends KinematicBody2D

var pos = global_position 
var last_pos = pos
onready var vars = get_node("/root/global")
var t = 0
var snapspeed = 1

func _ready():
	pos = global_position

func _process(delta):
	if last_pos != pos:
		t = 0
		last_pos = pos
	t+=delta*snapspeed
	t=clamp(t,0,1)
	global_position = global_position.linear_interpolate(pos, t)
	snapspeed = 1
