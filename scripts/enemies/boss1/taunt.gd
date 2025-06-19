extends Enemy_Damage_State

@export var idle: State

# Called when the node enters the scene tree for the first time.
func enter():
	parent.animations.play("taunt")
	parent.animations.advance(0)

#func exit():
	#parent.guard = [8,8,8,8,3]
	#print("setting it back: ")
	#print(parent.guard)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func process(delta):
	if !parent.animations.is_playing():
		parent.handle_state()
		return idle
	return null

func taunt():
	parent.taunt_complete()
