extends KinematicBody2D

onready var tentajoint = preload("res://preload/tentajoint.tscn")
onready var tentapart = preload("res://preload/tentapart.tscn")
onready var tentahand = preload("res://preload/tentahand.tscn")
onready var vars = get_node("/root/global")
var loops = 20
onready var line = $line
var arr_loops = []
var hand

func _ready():
	var parent = self
	for i in range (loops):
		if i == loops-1: 
			var child = addHand(parent)
			addLink(parent, child)
		else: 
			var child = addLoop(parent)
			line.add_point(child.position)
			addLink(parent, child)
			parent = child
	line.points.remove(len(line.points)-1)

func _process(delta):
	arr_loops[0].global_position = global_position
	arr_loops[1].global_position = (global_position+arr_loops[1].global_position)/2
	position = Vector2(0,0)
	for i in range(len(line.points)):
		line.points[i] = arr_loops[i].position

func addLoop(parent):
	var loop = tentapart.instance()
	loop.position = parent.position
	loop.position.x += 4
	loop.position.y += 4
	arr_loops.append(loop)
	add_child(loop)
	return loop
	
func addLink(parent, child):
	var pin = tentajoint.instance()
	pin.node_a = parent.get_path()
	pin.node_b = child.get_path()
	parent.add_child(pin)

func addHand(parent):
	var loop = tentahand.instance()
	loop.position = parent.position
	loop.position.y += 100/loops
	arr_loops.append(loop)
	hand = loop
	add_child(loop)
	return loop

func moveHand(pos):
	hand.pos = pos

func snapHand(pos):
	hand.pos = pos
	hand.snapspeed = 60

func getHand():
	return hand.pos
	
