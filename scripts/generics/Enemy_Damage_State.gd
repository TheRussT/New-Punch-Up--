class_name Enemy_Damage_State

extends State

# first make it work, then make it efficient
func damage(value):
	var guard_position = (value >> 8) & 7
	if parent.guard[guard_position] == 8:
		if guard_position < 2:
			damage_react(24, 1, parent.get_child(4).get_child(5)) # can change later high block
		elif guard_position < 4:
			damage_react(24, 1, parent.get_child(4).get_child(12)) # low block  14
		else:
			pass
		parent.guard = parent.idle_guard
		return 8
	elif parent.guard[guard_position] == 7:
		parent.stamina -= 1
		parent.ring.update_enemy_stam(parent.stamina)
		parent.handle_state()
		if guard_position < 2:
			damage_react(32, 2, parent.get_child(4).get_child(5))
		elif guard_position < 4:
			damage_react(32, 2, parent.get_child(4).get_child(12)) #14
		else:
			pass
		if parent.stamina < 1:
			parent.state_machine.change_state(parent.get_child(4).get_child(18))
		else:
			parent.guard = parent.idle_guard
		return 7
	elif parent.guard[guard_position] == 6:
		damage_react(8, 0, parent.get_child(4).get_child(1))
		parent.guard = parent.idle_guard
		return 6
	elif parent.guard[guard_position] == 5:
		parent.stamina -= 1
		parent.ring.update_enemy_stam(parent.stamina)
		parent.handle_state()
		damage_react(12, 0, parent.get_child(4).get_child(1))
		if parent.stamina < 1:
			parent.state_machine.change_state(parent.get_child(4).get_child(18))
		else:
			parent.guard = parent.idle_guard
		return 5
	elif parent.guard[guard_position] == 4:
		if guard_position < 2:
			damage_react(24, 0, parent.get_child(4).get_child(1))
		elif guard_position < 4:
			damage_react(24, 0, parent.get_child(4).get_child(1))
		else:
			pass
		return 4
	elif parent.guard[guard_position] >= 0:
		parent.health -= value & 255
		if guard_position == 0:
			damage_react(14, 3, parent.get_child(4).get_child(7)) # high right
		elif guard_position == 1:
			damage_react(14, 3, parent.get_child(4).get_child(6)) # high left
		elif guard_position == 2:
			damage_react(14, 3, parent.get_child(4).get_child(14)) # low right 16
		elif guard_position == 3:
			damage_react(14, 3, parent.get_child(4).get_child(13)) # low left 15
		else:
			damage_react(32, 4, parent.get_child(4).get_child(6)) # high left
			#if parent.guard_position == 0 set inst ko flag
			
			if parent.available_hits > 1:
				parent.health -= 4
			if parent.guard[guard_position] == 0:
				parent.get_child(4).get_child(3).fall_type = 4
				parent.ring.enemy_ko_table[1] = parent.ring.enemy_ko_table[0]
				parent.health -= parent.health
			if parent.health < 1:
				parent.shake_timer = 0.333
				parent.total_shake_time = 0.333
				return 0
			parent.stamina -= (value & 255)/8
			parent.ring.update_enemy_stam(parent.stamina)
			parent.handle_state()
			return 3
			
		if parent.guard[guard_position] == 0:
			parent.get_child(4).get_child(3).fall_type = 4
			parent.health -= parent.health
		#if parent.guard[guard_position] == 1:
			#parent.available_hits = 4
		if parent.health < 1:
			parent.shake_timer = 0.167
			parent.total_shake_time = 0.167
			parent.shake_magnitude = 4
			return 0
		if parent.available_hits > 1:
			parent.shake_timer = 0.05
			parent.total_shake_time = 0.05
			parent.shake_magnitude = 2
			#parent.handle_state()
			return 1
		parent.stamina -= 1
		parent.ring.update_enemy_stam(parent.stamina)
		parent.handle_state()
		if parent.guard[guard_position] == 2:
			return 2
		return 3
	else:
		return -1

func damage_react(time, magnitude, state):
	parent.shake_timer = float(time)/120
	parent.shake_magnitude = magnitude
	parent.total_shake_time = parent.shake_timer
	parent.state_machine.change_state(state)
