extends KinematicBody2D

var rng = RandomNumberGenerator.new()
onready var tentacle = preload("res://preload/tentacle.tscn")
onready var mucus = preload("res://preload/mucus.tscn")
onready var vars = get_node("/root/global")
onready var floordetect = $floordetect
onready var ceildetect = $ceildetect
onready var wallldetect = $wallldetect
onready var wallrdetect = $wallrdetect
onready var sensor = $sensor
onready var body = $body
onready var head = $body/head
onready var wings = $body/wings
onready var wingl = $body/wings/wingl
onready var wingr = $body/wings/wingr
onready var cape = $cape
onready var light = $light
var num_tent = 10
var tentacles = []
var velocity = Vector2(0,0)
var rng_vec = Vector2(rng.randf_range(-1,1),rng.randf_range(0,1)).normalized()*100
var speed = 20
var maxspeed = 300
var lrdir = Input.get_action_strength("right")-Input.get_action_strength("left")
var uddir = Input.get_action_strength("down")-Input.get_action_strength("up")
var gravity = true
var distance = 1
var cdistance = 1
var jumpclock = 0
var jumpcharge = 0
var cjumpclock = 0
var cjumpcharge = 0
var glideclock = 0
var glideangle = 0
var glidecharge = 0
var glidedir
var glideamount = 1
var glideflooraversion = 3
var canglide = glideamount
var canmucus = true
var maxmucus = 150
var mucuscharge = maxmucus
var mucuscooldown = 0
var mucuscdtime = 50
var move = true
var launchpos = Vector2(0,0)
var launched = false
var launcht = 0
var launchcooldown = 0
var launchdir = Vector2(0,0)
var lastdir = Vector2(0,0)
var lastx = 1
var lasty = 1
var grabbed = false


func _ready():
	light.enabled = true
	for i in range(num_tent):
		var tnt = tentacle.instance()
		tentacles.append(tnt)
		self.add_child(tnt)
	for i in range(num_tent):
		if i <= num_tent/2: 
			tentacles[i].get_node("line").default_color = Color(0.8,0,0.5,1)
		#else:
		#	tentacles[i].get_node("line").default_color = Color(1,0,2.7,1)

func _process(delta):
	
	if Vector2(lrdir,uddir).normalized() != Vector2(0,0): lastdir = Vector2(lrdir,uddir).normalized()
	if lrdir!=0: lastx = lrdir/abs(lrdir)
	if uddir!=0: lasty = uddir/abs(uddir)
	
	lrdir = Input.get_action_strength("right")-Input.get_action_strength("left")
	uddir = Input.get_action_strength("down")-Input.get_action_strength("up")
	if glideclock < 80:
		body.rotation = deg2rad(velocity.x)/10
		
	if Input.is_action_just_pressed("reload"):get_tree().change_scene(get_tree().current_scene.filename)
	

	if Input.is_action_just_pressed("jump") and jumpclock == 0 and floordetect.is_colliding() and glideclock == 0: jumpclock = 100
	if jumpclock > 0: jump()
	if Input.is_action_just_pressed("jump") and cjumpclock == 0 and ceildetect.is_colliding() and glideclock == 0: cjumpclock = 100
	if cjumpclock > 0: cjump()
	
	if floordetect.is_colliding():
		distance = global_position.distance_to(floordetect.get_collision_point())
	if ceildetect.is_colliding():
		cdistance = global_position.distance_to(ceildetect.get_collision_point())
	
	#glide
	if Input.is_action_just_pressed("l2") and canglide > 0:
		glideclock = 100
		move = false
		wings.scale.y = 0
		canglide -= 1 
		head.rotation = PI/2
	if ((Input.is_action_pressed("l2") and glideclock > 0) or glideclock > 0):
		glide()
	else:
		glideclock = floor(glideclock*0.6)
	if Input.is_action_just_released("l2") or glideclock < 20:
		move = true
	if glideclock ==0:
		head.rotation = deg2rad(velocity.x/100)
		if vars.senspoints != []: canglide = glideamount
	if velocity.x != 0: velocity.x = velocity.x - (velocity.x/abs(velocity.x))
	if glideclock == 0: 
		velocity.x = clamp(velocity.x,-maxspeed,maxspeed)
		velocity.y = clamp(velocity.y,-maxspeed*2,maxspeed*2)
	
	#grab
	if Input.is_action_pressed("r2"):
		if glideclock < 20 and vars.senspoints != []:
			grab()
			grabbed = true
		elif vars.senspoints != []: glideclock = 20
	if Input.is_action_just_released("r2"):
		grabbed = false
	
	#mucus
	if mucuscharge < 0: mucuscharge = 0
	if canmucus:
		if Input.is_action_pressed("l1") and jumpclock < 80 and cjumpclock < 80 and mucuscharge > 0 and glideclock < 70:
			var mcs = mucus.instance()
			var mucuspeed = 100 if glideclock > 0 else 0
			mucuscharge -= 1 if glideclock > 0 else 0
			velocity += Vector2(lrdir,uddir) * mucuspeed
			mcs.position = -velocity/20 + global_position
			if glideclock != 0: snap2pos(mcs.position)
			get_parent().add_child(mcs)
			light.energy = 0.5 +  deg2rad (mucuscharge)/ PI 
			if glideclock == 0 and mucuscharge < maxmucus: mucuscharge += 1
			if jumpclock > 50 or cjumpclock > 50:
				move_and_slide(velocity * 1.5)
				mucuscharge -= 5
			if grabbed: 
				move_and_slide(velocity * 1.5)
				mucuscharge -= 2
		if Input.is_action_just_released("l1"):
			mucuscooldown = mucuscdtime
			mucuscharge -= 3
		
		if !Input.is_action_pressed("l1"):
			if light.energy > 0.5: light.energy -= 0.05
			if mucuscooldown == 0:
				if glideclock < 20:
					if mucuscharge < maxmucus: mucuscharge += 2
				else:
					if mucuscharge < maxmucus: mucuscharge +=1
		
		if mucuscooldown > 0: mucuscooldown -= 1
	
	wings.scale.y = clamp(wings.scale.y, 0,2)
	
	for i in tentacles:
			velocity+= (i.getHand()-global_position)/1000
	
	if move: move()
	velocity.x = floor(velocity.x)
	velocity.y = floor(velocity.y)
	if glideclock == 0: 
		wings.scale.y = floor(wings.scale.y*0.9)
		ceilhover()
	
	
	cape.clear_points()
	if glideclock == 0:
		for l in range(tentacles[0].loops - 1):
			for t in tentacles:
				cape.add_point(t.arr_loops[l].position)

	move_and_slide(velocity)



func anglediff(angle1, angle2):
	var diff = angle2 - angle1
	return diff if abs(diff) < PI else diff + (2*PI * -sign(diff))

func snap2pos(pos):
	for i in tentacles:
		i.snapHand(pos)

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

func randmovenocool(xrand,yrand):
	rng.randomize()
	rng_vec = Vector2(rng.randf_range(xrand[0],xrand[1]),rng.randf_range(yrand[0],yrand[1])).normalized()
	rng_vec = rng_vec*100+global_position
	#if vars.senspoints != []: rng_vec = vars.senspoints[rng.randi_range(0, len(vars.senspoints)-1)]
#	if vars.tick:
#		for i in tentacles:
#			rng.randomize()
#			i.moveHand()
	for i in tentacles:
		rng.randomize()
		rng_vec = Vector2(rng.randf_range(xrand[0],xrand[1]),rng.randf_range(yrand[0],yrand[1])).normalized()
		rng_vec = rng_vec*100+global_position
		i.moveHand(rng_vec)

func randnearby():
	rng.randomize()
	if vars.senspoints == [] and !launched: 
		for i in tentacles:
			#i.snapHand(global_position)
			randmove([-0.1,0.1],[-0.1,0.1])
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
			i.moveHand(global_position)
	var magnitude = 1
	if vars.senspoints != []: 
		
		for i in tentacles:
			rng_vec = vars.senspoints[rng.randi_range(0, len(vars.senspoints)-1)]
			i.moveHand(rng_vec * magnitude)

func floorhover():
	if floordetect.is_colliding() and jumpclock == 0:
		velocity.y += (Input.get_action_strength("down")/5-Input.get_action_strength("up"))*80
		velocity.y = velocity.y*0.8
		velocity.y -= 50-distance
		velocity.y *= 0.9

func ceilhover():
	if ceildetect.is_colliding() and cjumpclock == 0:
		var moving = true if stepify(abs(velocity.x),10) > 0 or stepify(abs(velocity.y),50) > 0 else false
		velocity.y += (Input.get_action_strength("down")-Input.get_action_strength("up")/5)*100
		if cdistance < 50: velocity.y += (50-cdistance)
		velocity.y += 60 - cdistance
		velocity.y *= 0.9

func jump():
	if jumpclock == 100: jumpcharge = 0.3
	if jumpclock < 100 and jumpclock > 80:
		randnearby()
		velocity.y = (100-jumpclock)*6
		if Input.is_action_pressed("jump"): 
			jumpcharge+=0.15
		if Input.is_action_just_released("jump"): jumpclock = 81
	elif jumpclock == 80:
		randmovenocool([-1,1],[-1,1])
		velocity.y = -600 *jumpcharge
	elif jumpclock < 70:
		randmove([-1,1],[-1,1]) 
		if floordetect.is_colliding(): 
			if distance < 50: jumpclock = 1
	if ceildetect.is_colliding(): jumpclock = 1 
	if jumpclock == 20: jumpclock = 40
	jumpclock-=1

func cjump():
	if cjumpclock == 100: cjumpcharge = 0.3
	if cjumpclock < 100 and cjumpclock > 80:
		randnearby()
		velocity.y = (100-cjumpclock)*-6
		if Input.is_action_pressed("jump"): 
			cjumpcharge+=0.1
		if Input.is_action_just_released("jump"): cjumpclock = 81
	elif cjumpclock == 80:
		randmovenocool([-1,1],[-1,1])
		velocity.y = 600 *cjumpcharge
	elif cjumpclock < 70:
		randmove([-1,1],[-1,1]) 
		if floordetect.is_colliding(): cjumpclock = 1
	#if cjumpclock == 20: cjumpclock = 40
	cjumpclock-=1

func move():
	var movement = true if(Input.is_action_pressed("right") or Input.is_action_pressed("left") or Input.is_action_pressed("down") or Input.is_action_pressed("up")) else false
	var moving = true if stepify(abs(velocity.x),10) > 0 or stepify(abs(velocity.y),50) > 0 else false
	if launchcooldown == 0: floorhover()
	if moving and !launched and !grabbed: randnearby()
	velocity.x += lrdir*speed
	if gravity: velocity.y += 10

func respawn():
	global_position = Vector2(0,0)

func launch():
	body.rotation = launchdir.angle()
	var movement = true if(Input.is_action_pressed("right") or Input.is_action_pressed("left") or Input.is_action_pressed("down") or Input.is_action_pressed("up")) else false
	launched = true
	if vars.senspoints != []:
		if movement: launcht = 0
		launcht+=0.1
		launcht = clamp(launcht,0,1)
		launchdir = Vector2(lrdir,uddir).normalized() * 1000
		var destination = launchpos + Vector2(-lrdir,-uddir/2).normalized() * 20
		global_position = global_position.linear_interpolate(destination,launcht)

func glide():
	glideclock-=0.5
	snap2pos(global_position)
	wingl.rotation = deg2rad(fmod(glideclock,3)-1) *-2
	wingr.rotation = deg2rad(fmod(glideclock,3)-1) *2
	#randmove([-0.1,0.1],[-0.1,0.1])
	if glideclock > 80:
		glidecharge = 0
		glideclock-=0.5
		body.rotation += (2*PI)/20
		velocity = velocity*0.9
		wings.scale.y += 0.10
		if floordetect.is_colliding():
			velocity.y-=100/distance
	if glideclock == 80:
		glideangle = 0
		glideclock-=0.5
		velocity = lastdir * 666
	if glideclock < 80 and glideclock > 19: 
		body.look_at(velocity.normalized()+body.global_position)
#		head.rotation = -body.rotation + deg2rad(velocity.x/20)
	if glideclock < 70:
		if !Input.is_action_pressed("l2") and glideclock > 20: glideclock = 19
		#glideangle += deg2rad((lrdir-uddir)) 
		glidedir = Vector2(lrdir,uddir).normalized()
		glideangle *= .95
		if glidedir == Vector2(0,0): glideangle /= 2
		else: glideangle += (velocity.angle_to(glidedir)/500)
		if glidedir.angle() > 0:
			velocity /= 0.99
		else: 
			velocity *= 0.99*0.99
		velocity.y += 10
		if abs(glideangle) < .001: glideangle += 0.01
		velocity = velocity.rotated(glideangle)
		velocity = velocity.clamped(500)
		velocity.x += lrdir *10
		for i in vars.senspoints:
			velocity += (global_position-i)/1000
			glideangle += velocity.angle_to(global_position-i)/100000
		if floordetect.is_colliding():
			if velocity.angle() > PI/2:
				velocity = velocity.rotated(deg2rad(glideflooraversion))
			elif velocity.angle() < PI/2:
				velocity = velocity.rotated(deg2rad(-glideflooraversion))
			else: velocity = velocity.rotated(deg2rad(glideflooraversion))
		if ceildetect.is_colliding():
			if velocity.angle() > -PI/2:
				velocity = velocity.rotated(deg2rad(glideflooraversion))
			elif velocity.angle() < -PI/2:
				velocity = velocity.rotated(deg2rad(-glideflooraversion))
			else: velocity = velocity.rotated(deg2rad(glideflooraversion))
		if glideclock == 30 and Input.is_action_pressed("l2"): glideclock = 60
		for i in vars.senspoints:
			velocity -= i/5000
	if glideclock < 20:
		body.look_at(velocity.normalized()+body.global_position)
		body.rotation *= 20/glideclock
		glideclock = floor(glideclock)
		wings.scale.y = glideclock/10
		velocity.x *= 0.9
		ceilhover()
		floorhover()

func grab():
	var movement = true if(Input.is_action_pressed("right") or Input.is_action_pressed("left") or Input.is_action_pressed("down") or Input.is_action_pressed("up")) else false
	if false:
		jumpclock = 0
		cjumpclock = 0
		snap2pos(closestpoint())
		for i in tentacles:
			velocity+= (i.getHand()-global_position)/10
			velocity+= (i.getHand()-global_position)/10
			velocity+= (i.getHand()-global_position)/10
		velocity += Vector2(lrdir,uddir) * 40
		velocity *= 0.99
		randnearbynocool()
		if !movement: velocity *= 0.9
		#randmovenocool([-1,1],[-1,1])
		#if floordetect.is_colliding(): velocity.y-=100
		#if ceildetect.is_colliding(): velocity.y+=100
		if jumpclock < 50: jumpclock = 0
		if cjumpclock < 65: cjumpclock = 0
	jumpclock = 0
	cjumpclock = 0
	snap2pos(closestpoint())
	for i in tentacles:
		velocity+= (i.getHand()-global_position)/10
		velocity+= (i.getHand()-global_position)/10
		rng.randomize()
		i.moveHand(Vector2(rng.randf_range(-50,50),rng.randf_range(-50,50))+closestpoint())
	for j in vars.senspoints:
		velocity -= j/5000
	
	if floordetect.is_colliding(): velocity.y-=100
	if ceildetect.is_colliding(): velocity.y+=100
	if wallldetect.is_colliding(): velocity.x+=100
	if wallrdetect.is_colliding(): velocity.x-=100
	if !movement: velocity *= 0.9
	velocity += Vector2(lrdir,uddir) * 100
	if jumpclock < 50: jumpclock = 0
	if cjumpclock < 65: cjumpclock = 0

func closestpoint():
	var closestpoint = global_position
	if vars.senspoints != []:
		var closest = global_position.distance_to(vars.senspoints[0])
		for i in vars.senspoints:
			if global_position.distance_to(i) < closest: 
				closest = global_position.distance_to(i)
				closestpoint = i
	return closestpoint
