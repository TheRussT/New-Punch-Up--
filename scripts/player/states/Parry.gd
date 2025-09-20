extends State

@export var block: State
@export var left_jab: State
@export var right_jab: State

# Called when the node enters the scene tree for the first time.
func enter():
	parent.animations.play("parry")
	parent.animations.advance(0)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func process(delta):
	if !parent.animations.is_playing():
		return block
	if parent.input_buffer.has("ui_accept"):
		return left_jab
	elif parent.input_buffer.has("ui_cancel"):
		return right_jab
	return null

func damage(value):
	if parent.animations.get_current_animation_position() > 0.0833:
		if (value >> 13 & 1) == 1:
			parent.initiate_shake_f(0.267,1)
			return 4
		else:
			if value >> 14 & 1 == 1:
				parent.initiate_shake_f(0.2,2)
				return 3
				
	parent.health -= value & 255
	parent.stamina -= value >> 32
	parent.stamina_recovery_progress = 0
	# update here as needed
	if (value >> 12 & 1) == 1:
	# right
		parent.state_machine.change_state(parent.get_child(2).get_child(4))
	else:
		parent.state_machine.change_state(parent.get_child(2).get_child(3))
	parent.initiate_shake_i((value >> 16) & 255,(value >> 24) & 7)
	if parent.health <= 0:
		parent.initiate_shake_f(0.267,4)
		return 0
	elif parent.stamina <= 0:
		return 1
	return 2
