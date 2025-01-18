extends State

@export var idle: State
@export var high_left: State
@export var high_right: State
@export var low_left: State
@export var low_right: State

var daze_timer

# Called when the node enters the scene tree for the first time.
func enter():
	daze_timer = 400
	parent.animations.play("daze")


# Called every frame. 'delta' is the elapsed time since the previous frame.
func process(delta):
	daze_timer -= 1
	if daze_timer <= 0:
		return idle
	return null
