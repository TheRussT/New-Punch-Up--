extends "res://scripts/generics/general_enemy.gd"

enum {
	MAIN, MAIN_TIRED, LOW, LOW_TIRED, PLAYER_TIRED, TAUNT
}
@export var hook : State
@export var hook_big : State
@export var jab : State
@export var taunt : State

var consecutive_jabs = 0
var consecutive_hooks = 0
var consecutive_idle_hits = 0
var total_idle_hits = 0
var idle_guard = [3,3,8,8,3]

var has_taunted = false

func _ready():
	animations = $Animations
	sprite = $Boss
	falling_sprite = $Boss_Falling
	stamina = 12
	stamina_max = 12
	stamina_next = 9
	guard = [3,3,8,8,3]
	schedule_state = MAIN
	enemy_schedule = {MAIN: [0x10200, 0x10040, jab, 0x10080, hook, 0x100c0, jab, 
		0x10040, 0x20109, 0x10050, hook, 0x30001],
		LOW: [0x10080, hook, 0x20003, 0x10020, hook, 0x20006, 0x10060, jab, 
		0x10090, jab, 0x20008],
		MAIN_TIRED: [0x1000c0, jab, 0x20003, 0x10060, jab, 0x20006, 0x10010, hook_big, 
		0x20009, 0x30006],
		LOW_TIRED: [0x10010, hook, 0x20003, 0x10080, hook, 0x20003], #last was hook big
		PLAYER_TIRED: [0x10010, hook, 0x20003, 0x10040, hook, 0x30000],
		TAUNT: [taunt, 0x30000]
	}
	state_machine.init(self)
	handle_state_schedule()

func handle_state():
	#if we dont have stamina, change state to stamina_loss
	#if player has no stamina change state to player tired
	#elif 
	if player.stamina < 1:
		if schedule_state != PLAYER_TIRED:
			schedule_index = 0
		schedule_state = PLAYER_TIRED
		#handle_state_schedule()
	else:
		if schedule_state == PLAYER_TIRED:
			schedule_state = MAIN
		if schedule_state == TAUNT && has_taunted == true:
			schedule_state = MAIN
		if health > 48:
			if schedule_state == LOW:
				schedule_state = MAIN
				schedule_index = 0
				#handle_state_schedule()
			if schedule_state == LOW_TIRED:
				schedule_state = MAIN_TIRED
				schedule_index = 0
				#handle_state_schedule()
			if stamina < 5 && schedule_state == MAIN:
				schedule_state = MAIN_TIRED
				schedule_index = 0
				#handle_state_schedule()
			if stamina > 7 && schedule_state == MAIN_TIRED:
				schedule_state = MAIN
				schedule_index = 0
				#handle_state_schedule()
		elif health <= 48:
			if schedule_state == MAIN:
				schedule_state = LOW
				schedule_index = 0
				#handle_state_schedule()
			if schedule_state == MAIN_TIRED:
				schedule_state = LOW_TIRED
				schedule_index = 0
				#handle_state_schedule()
			if stamina < 5 && schedule_state == LOW:
				schedule_state = LOW_TIRED
				schedule_index = 0
				#handle_state_schedule()
			if stamina > 7 && schedule_state == LOW_TIRED:
				schedule_state = LOW
				schedule_index = 0
				#handle_state_schedule()
	#handle_state_schedule()
	#print("schedule: " + str(schedule_state) + " index: " + str(schedule_index))

func check_conditions(value, result, state):
	if has_taunted:
		return
	# Keeps track of the stray hits and alternations etc.
	if (result == 3 || result == 2) && state == $State_Machine/Idle:
		consecutive_idle_hits +=1
		total_idle_hits += 1
		#print("was from idle, conscutive hits = " + str(consecutive_idle_hits))
		if (value >> 8 & 7) < 2:
			consecutive_jabs += 1
			consecutive_hooks = 0
			if consecutive_jabs > 1:
				idle_guard = [8,8,3,3,3]
				if consecutive_idle_hits == 7:
					idle_guard = [8,8,2,2,3]
			else:
				if consecutive_idle_hits == 7:
					idle_guard = [2,2,8,8,3]
		elif (value >> 8 & 7) < 4:
			consecutive_hooks += 1
			consecutive_jabs = 0
			if consecutive_hooks > 1:
				idle_guard = [3,3,8,8,3]
				if consecutive_idle_hits == 7:
					idle_guard = [2,2,8,8,3]
			else:
				if consecutive_idle_hits == 7:
					idle_guard = [8,8,2,2,3]
		if consecutive_idle_hits == 8:
			schedule_state = TAUNT
			schedule_timer = -1
			schedule_index = 0
			idle_guard = [8,8,8,8,3]
			stamina_regain_timer = -1000
			$State_Machine/Idle.animation = "idle_up"
		if total_idle_hits > 11:
			idle_guard = [8,8,8,8,3]
			stamina_regain_timer = -1000
			$State_Machine/Idle.animation = "idle_up"
	else:
		consecutive_idle_hits = 0
		consecutive_hooks = 0
		consecutive_jabs = 0
	
	# Checks 

func taunt_complete():
	has_taunted = true
