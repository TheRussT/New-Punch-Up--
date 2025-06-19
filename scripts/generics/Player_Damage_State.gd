class_name Player_Damage_State

extends State

# first make it work, then make it efficient
func damage(value):
	parent.health -= value & 255
	parent.stamina -= value >> 32 & 255
	# update here as needed
	if value >> 12 & 1 == 1:
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
