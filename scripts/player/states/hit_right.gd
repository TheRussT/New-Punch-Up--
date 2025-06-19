extends State

@export var idle: State
@export var falling: State

# Called when the node enters the scene tree for the first time.
func enter():
	parent.animations.play("right_hit")
	parent.animations.advance(0)
	parent.stars = 0
	parent.ring.handle_stars(0)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func process(delta):
	if !parent.animations.is_playing():
		return idle
	return null

func handle_ko():
	if parent.health < 1:
		parent.state_machine.change_state(falling)
