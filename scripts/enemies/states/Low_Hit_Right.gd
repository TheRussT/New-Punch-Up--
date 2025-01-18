extends State

@export var daze: State
@export var sent: State

# Called when the node enters the scene tree for the first time.
func enter():
	parent.animations.play("belly_hit_right")

# Called every frame. 'delta' is the elapsed time since the previous frame.
func process(delta):
	if !parent.animations.is_playing():
		if parent.available_hits > 1:
			parent.available_hits -= 1
			return daze
		else:
			return sent
	return null
