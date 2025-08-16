extends Enemy_Damage_State

@export var idle: State
#@export var high_left: State
#@export var high_right: State
#@export var low_left: State
#@export var low_right: State
@export var daze : State
@export var stamina_loss : State
@export var walking_up: State

var next_state: State

# Called when the node enters the scene tree for the first time.
func enter():
	next_state = idle
	parent.animations.play("jab")
	parent.animations.advance(0)

#func exit():
	#parent.guard = [8,8,8,8,3]
	#print("setting it back: ")
	#print(parent.guard)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func process(delta):
	if !parent.animations.is_playing():
		parent.handle_state()
		return next_state
	return null

func damage_player():
	var result = parent.damage_player(0x10214640d)
	# if punch lands avail_hits = 6, parent.changestae(daze)
	if result == 0: #32 frames
		parent.shake_timer = 0.267
		parent.shake_magnitude = 2
		parent.total_shake_time = 0.267
		next_state = walking_up
	elif result < 3: #20 frames
		parent.shake_timer = 0.167
		parent.shake_magnitude = 1
		parent.total_shake_time = 0.167
		parent.guard = parent.idle_guard
		parent.available_hits = 1
	elif result == 3: #24 frames
		parent.shake_timer = 0.2
		parent.shake_magnitude = 1
		parent.total_shake_time = 0.2
	elif result == 4: #32 frames
		parent.stamina -= 2
		parent.ring.update_enemy_stam(parent.stamina)
		parent.handle_state()
		parent.shake_timer = 0.267
		parent.shake_magnitude = 3
		parent.total_shake_time = 0.267
		parent.available_hits = 2
		if parent.stamina < 1:
			parent.state_machine.change_state(stamina_loss)
		else:
			parent.state_machine.change_state(daze)
	elif result == 5:
		parent.available_hits = 3
		parent.recovery_hits = 2
