extends State

@export var walking_down: State
var timer = 0.0
var duration = 2.5
var starting_x = 0
var starting_y = 0

# Called when the node enters the scene tree for the first time.
func enter():
	parent.animations.play("waiting")
	parent.animations.advance(0)
	parent.animations.speed_scale = 2
	starting_x = parent.position.x
	starting_y = parent.position.y
	timer = 0.0

func exit():
	parent.animations.speed_scale = 1
	parent.position.x = parent.base_x
	parent.position.y = parent.base_y
	parent.ring.player_got_up()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func process(delta):
	timer += delta
	
	if timer >= duration:
		return walking_down
	else:
		parent.position.x = int(starting_x + (timer/duration) * (parent.base_x - starting_x))
		parent.position.y = int(starting_y + (timer/duration) * (parent.base_y - starting_y))
	return null
