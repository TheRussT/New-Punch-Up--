extends Enemy_Damage_State

@export var idle: State
@export var falling: State
@export var stamina_loss : State

# Called when the node enters the scene tree for the first time.
func enter():
	parent.spit.visible = true
	if parent.recovery_hits > 0:
		parent.recovery_hits -= 1
		parent.animations.play("jaw_sent_left_long")
	else:
		parent.animations.play("jaw_sent_left")
	parent.animations.advance(0)
	parent.sprite.flip_h = 1

func exit():
	parent.star.visible = false
	parent.spit.visible = false
	parent.sprite.flip_h = 0
	parent.spit.flip_h = 0

# Called every frame. 'delta' is the elapsed time since the previous frame.
func process(delta):
	if !parent.animations.is_playing():
		parent.guard = parent.idle_guard
		parent.ring.set_timer_speed(2)
		return idle
	return null

func check_kod():
	if parent.health <= 0:
		if falling.fall_type != 4:
			falling.fall_type = 1
		parent.state_machine.change_state(falling)
	elif parent.stamina <= 0:
		parent.state_machine.change_state(stamina_loss)

func check_star():
	if parent.star_flag:
		parent.star_flag = false
		parent.star.visible = true

func recovery_guard():
	parent.guard = parent.left_high_recovery_guard
