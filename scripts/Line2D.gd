extends Line2D


# Called when the node enters the scene tree for the first time.
func _ready():
	add_point(global_position)
	add_point(get_parent().cast_to)


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
