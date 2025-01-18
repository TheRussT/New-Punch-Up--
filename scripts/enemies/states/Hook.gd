extends State

@export var idle: State
@export var high_left: State
@export var high_right: State
@export var low_left: State
@export var low_right: State

# Called when the node enters the scene tree for the first time.
func enter():
	parent.animations.play("hook")


# Called every frame. 'delta' is the elapsed time since the previous frame.
func process(delta):
	if !parent.animations.is_playing():
		return idle
	return null
