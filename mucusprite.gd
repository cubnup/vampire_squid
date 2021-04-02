extends Sprite

var rng = RandomNumberGenerator.new()
var lifetime


# Called when the node enters the scene tree for the first time.
func _ready():
	modulate.a = 1.1
	$light.modulate.a = 0.06
	$light2.modulate.a = 0.04
	$light3.modulate.a = 0.02
	lifetime = 200

func _process(delta):
	rotation += 1
	lifetime -= 1
	scale *= .95
	rng.randomize()
	get_parent().linear_velocity.x += rng.randf_range(-10,10)
	get_parent().linear_velocity.y += rng.randf_range(-10,10)
	if lifetime <= 0: get_parent().queue_free()
