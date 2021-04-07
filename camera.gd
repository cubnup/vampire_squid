extends Camera2D


# Declare member variables here. Examples:
# var a = 2
# var b = "text"
var aimdir = Vector2(0,0)
var zoomlevels = [0.5,1,2,3,4]
var zoomlevel = 1
var t = 0

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if t < 1: t+= delta
	aimdir.x = Input.get_action_strength("rsright")-Input.get_action_strength("rsleft")
	aimdir.y = Input.get_action_strength("rsdown")-Input.get_action_strength("rsup")
	position += aimdir.normalized()*10
	position = position.clamped(300)
	if aimdir == Vector2(0,0): position *= .9
	if Input.is_action_just_pressed("rspress"): 
		zoomlevel +=1
		t = 0
	zoomlevel = fmod(zoomlevel,len(zoomlevels))
	zoom = zoom.linear_interpolate(Vector2(zoomlevels[zoomlevel],zoomlevels[zoomlevel]),t)
