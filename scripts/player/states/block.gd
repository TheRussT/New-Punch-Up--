extends State

@export var idle: State
@export var left_jab: State
@export var right_jab: State

# Called when the node enters the scene tree for the first time.
func enter():
	pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
func process(delta):
	if !parent.input_buffer.has("ui_up"):
		return idle
	if parent.input_buffer.has("ui_accept"):
		return left_jab
	if parent.input_buffer.has("ui_cancel"):
		return right_jab
	return null

func damage(value):
	if value >> 14 & 1 == 1:
		parent.shake_timer = 0.2
		parent.shake_magnitude = 3
		parent.total_shake_time = 0.2
		parent.stamina -= ((value >> 32) / 2) + 1
		
		return 3
	else:
		parent.health -= value & 255
		parent.stamina -= value >> 32
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
