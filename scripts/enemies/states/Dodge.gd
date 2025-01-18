extends State

@export var idle: State

# Called when the node enters the scene tree for the first time.
func enter():
	parent.animations.play("dodge")


# Called every frame. 'delta' is the elapsed time since the previous frame.
func process(delta):
	if !parent.animations.is_playing():
		return idle
	return null
