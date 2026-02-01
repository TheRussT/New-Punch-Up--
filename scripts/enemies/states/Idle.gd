extends Enemy_Damage_State

#can probably comment out

@export var high_left: State
@export var high_right: State
@export var low_left: State
@export var low_right: State
@export var high_block: State
@export var low_block: State
@export var dodge: State

var animation = "idle"
var time_lowered = 0

func enter():
	#print(parent.idle_guard)
	time_lowered = parent.idle_time_guard_lowered - 0.04 * parent.consecutive_idle_hits
	parent.idle_multiplier = 1
	
	parent.consecutive_recovery_hits = 0
	
	if parent.schedule_timer < parent.idle_cooldown * 120 && parent.schedule_timer >= 0:
		parent.schedule_timer = parent.idle_cooldown * 120
	#if parent.stamina_regain_timer > 0.5:
		#parent.stamina_regain_timer -= 0.5
	parent.animations.play(animation)
	parent.animations.advance(0)
	parent.guard = parent.idle_guard_low

func exit():
	parent.idle_multiplier = 0.3

func process(delta):
	#print(delta)
	parent.schedule_timer -= delta * 120
	if time_lowered > 0:
		time_lowered -= delta
	else:
		parent.guard = parent.idle_guard
	if parent.schedule_timer <= 0:
		parent.advance_state()
