extends State

@export var idle: State

var is_active = false
# Called when the node enters the scene tree for the first time.
func enter():
	parent.animations.play("walking_up")
	parent.animations.advance(0)
	parent.animations.pause()
	is_active = false

# Called every frame. 'delta' is the elapsed time since the previous frame.
func process(delta):
	if is_active:
		if !parent.animations.is_playing():
			parent.ring.set_timer_speed(2)
			return idle
		return null

func activate(value):
	is_active = true
	parent.animations.play()
