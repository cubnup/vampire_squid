extends KinematicBody2D

var rng = RandomNumberGenerator.new()
onready var tentacle = preload("res://preload/tentacle.tscn")
onready var vars = get_node("/root/global")
onready var floordetect = $floordetect
onready var ceildetect = $ceildetect
onready var head = $head
var num_tent = 10
var tentacles = []
var velocity = Vector2(0,0)
var rng_vec = Vector2(rng.randf_range(-1,1),rng.randf_range(0,1)).normalized()*100
var jumpclock = 0
var speed = 20
var maxspeed = 300
var lrdir = Input.get_action_strength("right")-Input.get_action_strength("left")
var uddir = Input.get_action_strength("down")-Input.get_action_strength("up")
var distance = 1
var cdistance = 1
var jumpcharge = 0
var move = true
var launchpos = Vector2(0,0)
var launched = false
var launcht = 0
var launchcooldown = 0
var launchdir = Vector2(0,0)
var closestpoint = position
var closest = position


func _ready():
	for i in range(num_tent):
		var tnt = tentacle.instance()
		tentacles.append(tnt)
		self.add_child(tnt)
	for i in range(num_tent):
		if i <= num_tent/2: 
			tentacles[i].get_node("line").default_color = Color(0.8,0,0.1,1)
		#else:
		#	tentacles[i].get_node("line").default_color = Color(1,0,2.7,1)

func _process(delta):
	lrdir = Input.get_action_strength("right")-Input.get_action_strength("left")
	uddir = Input.get_action_strength("down")-Input.get_action_strength("up")
	head.rotation = deg2rad(velocity.x)/10
	if Input.is_action_just_pressed("reload"):get_tree().change_scene(get_tree().current_scene.filename)
	
	if move: move()
	ceilhover()
	move_and_slide(velocity)

	if Input.is_action_just_pressed("jump") and jumpclock == 0 and floordetect.is_colliding(): jumpclock = 100
	if jumpclock > 0: jump()
	
	if floordetect.is_colliding():
		distance = global_position.distance_to(floordetect.get_collision_point())
	if ceildetect.is_colliding():
		cdistance = global_position.distance_to(ceildetect.get_collision_point())
	
	#launch 
	if true:
		if Input.is_action_pressed("r2"): 
			randmove([-1,1],[-1,1])
		if (Input.is_action_pressed("r2") and vars.senspoints != []) or launched:
			if !launched: launchpos = global_position
			launch()
			launched = true
		if Input.is_action_just_released("r2"):
			launchpos = Vector2(0,0)
			maxspeed = 2300
			launchcooldown = 20
			if vars.senspoints != []: velocity = launchdir
			launchdir = Vector2(0,0)
		if launchcooldown>0: 
			launchcooldown -= 1
			#maxspeed -= 100
			velocity = velocity * 0.95
			velocity.y+=1
		if launchcooldown == 1: 
			launched = false
		if launchcooldown == 0: 
			maxspeed = 300
			move = true
		print(vars.clock, launched, cdistance)
	if velocity.x != 0: velocity.x = velocity.x - (velocity.x/abs(velocity.x))*(speed/5)
	velocity.x = clamp(velocity.x,-maxspeed,maxspeed)
	velocity.y = clamp(velocity.y,-maxspeed*2,maxspeed*2)

func randmove(xrand,yrand):
	rng.randomize()
	rng_vec = Vector2(rng.randf_range(xrand[0],xrand[1]),rng.randf_range(yrand[0],yrand[1])).normalized()
	rng_vec = rng_vec*100+global_position
	#if vars.senspoints != []: rng_vec = vars.senspoints[rng.randi_range(0, len(vars.senspoints)-1)]
#	if vars.tick:
#		for i in tentacles:
#			rng.randomize()
#			i.moveHand()
	match int(vars.clock):
		6:  tentacles[0].moveHand(rng_vec)
		12: tentacles[5].moveHand(rng_vec)
		18: tentacles[1].moveHand(rng_vec)
		24: tentacles[6].moveHand(rng_vec)
		30: tentacles[2].moveHand(rng_vec)
		36: tentacles[7].moveHand(rng_vec)
		42: tentacles[3].moveHand(rng_vec)
		48: tentacles[8].moveHand(rng_vec)
		54: tentacles[4].moveHand(rng_vec)
		60: tentacles[9].moveHand(rng_vec)

func randnearby():
	rng.randomize()
	if vars.senspoints == [] and !launched: 
		for i in tentacles:
			i.snapHand(global_position)
	var magnitude = 1
	if vars.senspoints != []: 
		rng_vec = vars.senspoints[rng.randi_range(0, len(vars.senspoints)-1)]
		match int(vars.clock):
			6:  tentacles[0].moveHand(rng_vec * magnitude)
			12: tentacles[5].moveHand(rng_vec * magnitude)
			18: tentacles[1].moveHand(rng_vec * magnitude)
			24: tentacles[6].moveHand(rng_vec * magnitude)
			30: tentacles[2].moveHand(rng_vec * magnitude)
			36: tentacles[7].moveHand(rng_vec * magnitude)
			42: tentacles[3].moveHand(rng_vec * magnitude)
			48: tentacles[8].moveHand(rng_vec * magnitude)
			54: tentacles[4].moveHand(rng_vec * magnitude)
			60: tentacles[9].moveHand(rng_vec * magnitude)

func randnearbynocool():
	rng.randomize()
	if vars.senspoints == [] or !floordetect.is_colliding(): 
		for i in tentacles:
			i.snapHand(global_position)
	var magnitude = 1
	if vars.senspoints != []: 
		
		for i in tentacles:
			rng_vec = vars.senspoints[rng.randi_range(0, len(vars.senspoints)-1)]
			i.moveHand(rng_vec * magnitude)

func floorhover():
	if floordetect.is_colliding() and jumpclock == 0:
		velocity.y += (Input.get_action_strength("down")-Input.get_action_strength("up"))*100
		velocity.y = velocity.y*0.8
		velocity.y -= 50-distance
		if distance < 50: velocity.y -= (100-distance)

func ceilhover():
	if ceildetect.is_colliding():
		velocity.y += (Input.get_action_strength("down")-Input.get_action_strength("up"))*100
		if cdistance < 50: velocity.y += (50-cdistance)
		var multiplier = cdistance/100
		print(multiplier)
		multiplier = clamp(multiplier,0.5,1)
		velocity.y = velocity.y*multiplier
		velocity.y = velocity.y - cdistance/10

func jump():
	if jumpclock == 100: jumpcharge = 0.3
	if jumpclock < 100 and jumpclock > 80:
		randnearby()
		velocity.y = (100-jumpclock)*6
		if Input.is_action_pressed("jump"): 
			jumpcharge+=0.1
		if Input.is_action_just_released("jump"): jumpclock = 81
	elif jumpclock == 80:
		print(jumpcharge)
		velocity.y = -500 *jumpcharge
	elif jumpclock < 50: 
		if floordetect.is_colliding(): 
			if distance < 50: jumpclock = 1
	if jumpclock == 20: jumpclock = 40
	jumpclock-=1

func move():
	var movement = true if(Input.is_action_pressed("right") or Input.is_action_pressed("left") or Input.is_action_pressed("down") or Input.is_action_pressed("up")) else false
	var moving = true if round(abs(velocity.x)) > 0 or round(abs(velocity.y)) > 0 else false
	if launchcooldown == 0: floorhover()
	if moving and !launched: randnearby()
	velocity.x += lrdir*speed
	velocity.y += 10

func respawn():
	global_position = Vector2(0,0)

func launch():
	head.rotation = launchdir.angle()
	var movement = true if(Input.is_action_pressed("right") or Input.is_action_pressed("left") or Input.is_action_pressed("down") or Input.is_action_pressed("up")) else false
	launched = true
	if vars.senspoints != []:
		if movement: launcht = 0
		launcht+=0.1
		launcht = clamp(launcht,0,1)
		launchdir = Vector2(lrdir,uddir).normalized() * 1000
		var destination = launchpos + Vector2(-lrdir,-uddir/2).normalized() * 20
		#global_position = global_position.linear_interpolate(destination,launcht)
