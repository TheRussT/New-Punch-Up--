extends Enemy_Damage_State

@export var idle: State

@export var animation_name: String
@export var follow_up: State

func enter():
	parent.animations.play(animation_name)
	parent.animations.advance(0)

func process(delta):
	if !parent.animations.is_playing():
		parent.handle_state()
		return idle
	return null

func check_player():
	var curr_state = parent.ring.player.state_machine.current_state
	# curr_state == parent.ring.player.get_child(2).get_child(9) ||
	# curr_state == parent.ring.player.get_child(2).get_child(14) ||
	if (curr_state == parent.ring.player.get_child(2).get_child(10) ||
	curr_state == parent.ring.player.get_child(2).get_child(15)):
		parent.state_machine.change_state(follow_up)
