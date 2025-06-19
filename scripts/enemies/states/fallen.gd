extends State

@export var getup: State

# Called when the node enters the scene tree for the first time.
func enter():
	parent.sprite.visible = false
	parent.falling_sprite.visible = true
	parent.animations.play("falling_down")
	parent.animations.advance(0)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func process(delta):
	return null

func activate(value):
	#print("is activated")
	getup.getup_value = value
	parent.state_machine.change_state(getup)
