extends State

@export var walking_down: State

# Called when the node enters the scene tree for the first time.
func enter():
	parent.animations.play("walking_up")
	parent.animations.advance(0)
	parent.ring.set_timer_speed(0)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func process(delta):
	if !parent.animations.is_playing():
		return walking_down
	return null
