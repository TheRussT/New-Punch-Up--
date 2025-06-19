extends State

@export var idle: State
@export var falling: State
@export var stamina_loss : State

# Called when the node enters the scene tree for the first time.
func enter():
	parent.animations.play("jaw_sent_right")
	parent.animations.advance(0)

func exit():
	parent.star.visible = false

# Called every frame. 'delta' is the elapsed time since the previous frame.
func process(delta):
	if !parent.animations.is_playing():
		parent.guard = parent.idle_guard
		parent.ring.set_timer_speed(2)
		return idle
	return null

func check_kod():
	if parent.health <= 0:
		falling.fall_type = 0
		parent.state_machine.change_state(falling)
	elif parent.stamina <= 0:
		parent.state_machine.change_state(stamina_loss)

func check_star():
	if parent.guard[0] == 2:
		parent.star.visible = true
