extends Node

var clock = 0
var clockspeed = 1
var tick = false
var senspoints = []

func _ready():
	pass


func _process(delta):
	tick = true if int(clock) == 1 else false
	clock = fmod(clock,60)+clockspeed*2
	
