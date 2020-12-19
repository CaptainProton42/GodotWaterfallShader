extends MeshInstance

var time = 0.0

func _process(delta):
	time += delta
	translation.y = 0.5 * (sin(time) + 1.0)