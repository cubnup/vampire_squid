extends PinJoint2D


# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


func _process(delta):
	if get_node(node_a).get_class() == "RigidBody2D": 
		bias = 0+(get_node(node_a).linear_velocity).length()
	bias = clamp(bias,0,0.9)
	if Input.is_action_pressed("r2"): softness = 0.5
	else: softness = 1
