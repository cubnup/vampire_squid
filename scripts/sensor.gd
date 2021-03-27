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
	for i in senses:
		if i.is_colliding():
			vars.senspoints.append(i.get_collision_point())
	#if vars.senspoints != []: print(vars.senspoints[0])
