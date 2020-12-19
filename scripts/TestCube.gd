extends MeshInstance

var time = 0.0

func _process(delta):
	time += delta
	translation.x = 0.5 * sin(time) + 0.5
