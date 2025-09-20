extends State

@export var idle: State

# Called when the node enters the scene tree for the first time.
func enter():
	parent.animations.play("right_dodge_recovery")
	parent.animations.advance(0)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func process(delta):
	if !parent.animations.is_playing():
		return idle
	return null

func damage(value):
	if parent.animations.current_animation_position < 0.05 && (value >> 9) & 1 == 0:
		if (parent.stamina < 1):
			parent.stamina_recovery_progress += value & 255
			if parent.stamina_recovery_threshold <= parent.stamina_recovery_progress:
				if parent.sprite.material.get_shader_parameter("tolerance") == 0.1:
					parent.sprite.material.set_shader_parameter("tolerance", 0.0)
				parent.stamina = parent.stamina_recovered_amount
				parent.stamina_recovery_progress = 0
				parent.enemy.handle_state()
		return 5
	else:
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
