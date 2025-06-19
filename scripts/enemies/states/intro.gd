extends State

@export var repositioning: State

# Called when the node enters the scene tree for the first time.
func enter():
	parent.position.x = 196
	parent.position.y = 60
	parent.animations.play("intro")
	parent.animations.advance(0)

func exit():
	#parent.handle_state()
	pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
func process(delta):
	if !parent.animations.is_playing():
		return repositioning
	return null
