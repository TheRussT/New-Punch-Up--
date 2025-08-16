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
var consecutive_recovery_hits = 0
var total_idle_hits = 0
var in_combo = false

var has_taunted = false
var previous_message = -1

func _ready():
	animations = $Animations
	sprite = $Boss
	falling_sprite = $Boss_Falling
	stamina = 12
	stamina_max = 12
	stamina_next = 9
	guard = [3,3,3,3,3]
	idle_guard = [3,3,3,3,3]
	left_high_recovery_guard = [3,3,3,3,3,1]
	right_high_recovery_guard = [3,3,3,3,3,1]
	left_low_recovery_guard = [3,3,3,3,3,1]
	right_low_recovery_guard = [3,3,3,3,3,1]
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
	if !has_taunted:
		for i in 4:
			if idle_guard[i] == 2:
				idle_guard[i] = 3 
		if result == 1:
			in_combo = true
			consecutive_idle_hits = 0
		if result > 3:
			consecutive_idle_hits = 0
	if (result == 3 || result == 2):
		if !has_taunted && in_combo:
			in_combo = false
			if (value >> 8 & 7) < 2:
				idle_guard[0] = 8
				idle_guard[1] = 8
				idle_guard[2] = 3
				idle_guard[3] = 3
			else:
				idle_guard[0] = 8
				idle_guard[1] = 8
				idle_guard[2] = 3
				idle_guard[3] = 3
		if (state == $State_Machine/High_Sent_Left || state == $State_Machine/High_Sent_Right
		 || state == $State_Machine/Low_Sent_Left || state == $State_Machine/Low_Sent_Right):
			consecutive_idle_hits = 0
			consecutive_recovery_hits += 1
			if consecutive_recovery_hits > 1:
				left_high_recovery_guard = [2,2,2,2,3,1]
				right_high_recovery_guard = [2,2,2,2,3,1]
				left_low_recovery_guard = [2,2,2,2,3,1]
				right_low_recovery_guard = [2,2,2,2,3,1]
		else:
			if !has_taunted && state == $State_Machine/Idle:
				#print("cons idle hit")
				consecutive_idle_hits += 1
				total_idle_hits += 1
				if consecutive_idle_hits > 0 && consecutive_idle_hits % 3 == 0:
					if (value >> 8 & 7) < 2:
						idle_guard[0] = 8
						idle_guard[1] = 8
						idle_guard[2] = 3
						idle_guard[3] = 3
					else:
						idle_guard[0] = 3
						idle_guard[1] = 3
						idle_guard[2] = 8
						idle_guard[3] = 8
				if consecutive_idle_hits == 8:
					for i in 4:
						if idle_guard[i] == 3:
							idle_guard[i] = 2
				if total_idle_hits > 8:
					var temp_star = idle_guard[4]
					idle_guard = [8,8,8,8,temp_star]
					stamina_regain_timer = -1000
					$State_Machine/Idle.animation = "idle_up"
					schedule_state = TAUNT
					schedule_timer = -1
					schedule_index = 0
			else:
				consecutive_idle_hits = 0
			consecutive_recovery_hits = 0
			left_high_recovery_guard = [3,3,3,3,3,1]
			right_high_recovery_guard = [3,3,3,3,3,1]
			left_low_recovery_guard = [3,3,3,3,3,1]
			right_low_recovery_guard = [3,3,3,3,3,1]

func between_round_setup(round_number):
	if ring.enemy_times_kod == 0:
		Global.scene_manager.current_scene.player_message = "After he\npunches,\nhe leaves\nhimeself\nwide open!\n...      \nwell, more\nthan usual"
		Global.scene_manager.current_scene.enemy_message = "Monsieur!\nAre you\nnot aware?\ni come\nfrom a \nlong line\nof sir\nrendre-ers"
	elif has_taunted && previous_message != 1:
		Global.scene_manager.current_scene.player_message = "that old\nsir rendre\ngot wise\nand raised\nhis guard.\nAlthough\nhe looks a\nbit winded"
		Global.scene_manager.current_scene.enemy_message = "I'm not \neven old!\nI'm at the\nen-#cough#\nbeginning\nof my\ncareer!"
		previous_message = 1
	elif (ring.player_times_kod > ring.enemy_times_kod ||
	(ring.player_times_kod == ring.enemy_times_kod && health > player.health)):
		Global.scene_manager.current_scene.player_message = "I think I\ncan fit in\nsome extra\nhits if I\npunch\nright as\nhe's reco-\nvering!"
		Global.scene_manager.current_scene.enemy_message = "I need\nthis win\nto get \nover the\nhump...  \nI can't\nlose\nanother 90"
	else:
		if ring.enemy_times_kod > ring.player_times_kod:
			Global.scene_manager.current_scene.player_message = "left right\nleft right\nI'm\nadvancing\non you\nfast,\n\"monsieur\""
			Global.scene_manager.current_scene.enemy_message = "I was over\nconfident,\ni think\ni'll\ncapitulate\nsoon!"
		else:
			Global.scene_manager.current_scene.player_message = "I'll need\nto stay on\nmy toes.\nchip away\nat this\nloser's\nstamina"
			Global.scene_manager.current_scene.enemy_message = "Why does\nno one\nremember\nany of my\nprevious\nvictories?"
	Global.scene_manager.current_scene.set_up_messages(round_number)

func taunt_complete():
	has_taunted = true

func fight_setup():
	ring.background.texture = load("res://assets/backgrounds/Boxing_Ring_1_FinalNES.png")
