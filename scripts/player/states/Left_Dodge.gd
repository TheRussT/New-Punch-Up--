extends State

@export var recovery: State

# Called when the node enters the scene tree for the first time.
func enter():
	parent.animations.play("left_dodge")
	parent.input_buffer.erase("ui_left")
	parent.animations.advance(0)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func process(delta):
	if !parent.animations.is_playing():
		return recovery
	return null

func damage(value):
	if parent.animations.get_current_animation_position() > 0.1 && (value >> 11) & 1 == 0:
		if (parent.stamina < 1):
			parent.stamina_recovery_progress += value & 255
			#print(parent.stamina_recovery_progress)
			if parent.stamina_recovery_threshold <= parent.stamina_recovery_progress:
				parent.stamina = parent.stamina_recovered_amount
				parent.stamina_recovery_progress = 0
		return 5
	else:
		parent.health -= value & 255
	# update here as needed
		if (value >> 12 & 1) == 1:
		# right
			parent.state_machine.change_state(parent.get_child(2).get_child(4))
		else:
			parent.state_machine.change_state(parent.get_child(2).get_child(3))
		parent.initiate_shake_i((value >> 16) & 255,(value >> 24) & 7)
		if parent.health <= 0:
			return 0
		elif parent.stamina <= 0:
			return 1
	return 2

func check_light():
	if parent.input_buffer.has("ui_right"):
		parent.input_buffer.erase("ui_right")
		parent.state_machine.change_state(recovery)

func check_normal():
	if !parent.input_buffer.has("ui_left"):
		parent.state_machine.change_state(recovery)
