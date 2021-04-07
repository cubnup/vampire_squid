extends Node2D

onready var vars = get_node("/root/global")
onready var tentasense = preload("res://preload/tentasense.tscn")

var senses = []
var resolution = 180
var radius = 200
var grabsize = 1

# Called when the node enters the scene tree for the first time.
func _ready():
	for i in range(resolution):
		var sense = tentasense.instance()
		sense.cast_to = Vector2(radius,0).rotated(deg2rad(i * (360/resolution)))
		senses.append(sense)
		self.add_child(sense)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	vars.senspoints = []
	if Input.is_action_pressed("r2"):
		print (closestcast())
		for i in senses:
			if i.is_colliding():
				if i.get_collider() != closestcollider():
					i.enabled = false
#			if closestcast()!=null:
#				if abs(senses[closestcast()].cast_to.angle()-i.cast_to.angle()) > grabsize:
#					i.enabled = false
			else: i.enabled = true
	for i in senses:
		if i.is_colliding():
			vars.senspoints.append(i.get_collision_point())

func closestcollider():
	var closestcollider = null
	var closest = 201
	for i in senses:
		if i.is_colliding():
			if global_position.distance_to(i.get_collision_point()) < closest: 
				closest = global_position.distance_to(i.get_collision_point())
				closestcollider = i.get_collider()
	return closestcollider 


func closestcast():
	var closestcast = null
	var closest = 201
	for i in range(len(senses)):
		if senses[i].is_colliding():
			if global_position.distance_to(senses[i].get_collision_point()) < closest: 
				closest = global_position.distance_to(senses[i].get_collision_point())
				closestcast = i
	return closestcast 
