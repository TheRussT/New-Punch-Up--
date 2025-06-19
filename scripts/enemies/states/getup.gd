extends State

@export var repositioning: State
@export var fallen: State

var getup_value = 0

# Called when the node enters the scene tree for the first time.
func enter():
	parent.sprite.visible = false
	parent.falling_sprite.visible = true
	parent.animations.play("getting_up")
	parent.animations.advance(0)

func exit():
	parent.sprite.visible = true
	parent.falling_sprite.visible = false

# Called every frame. 'delta' is the elapsed time since the previous frame.
func process(delta):
	if !parent.animations.is_playing():
		#parent.ring.enemy_got_up()
		repositioning.duration = abs(float(parent.position.x - parent.base_x)/44)
		parent.position.y -= 12
		parent.falling_sprite.flip_h = false
		return repositioning
	return null

func can_get_up(value):
	#print("getup_value: " + str(getup_value) + ", value passed: " + str(value))
	if value >= getup_value:
		parent.ring.enemy_fell_down()
		parent.state_machine.change_state(fallen)
