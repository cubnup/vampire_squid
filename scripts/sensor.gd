extends Node2D

onready var vars = get_node("/root/global")
onready var tentasense = preload("res://preload/tentasense.tscn")

var senses = []
var resolution = 360
var radius = 200

# Called when the node enters the scene tree for the first time.
func _ready():
	for i in range(360):
		var sense = tentasense.instance()
		sense.cast_to = Vector2(radius,0).rotated(deg2rad(i))
		senses.append(sense)
		self.add_child(sense)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	vars.senspoints = []
	if Input.is_action_pressed("r2"):
		pass
		for i in senses:
			if i.is_colliding():
				if i.get_collider() == closestcollider():
					vars.senspoints.append(i.get_collision_point())
	else:
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
