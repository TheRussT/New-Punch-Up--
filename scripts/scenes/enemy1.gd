extends "res://scripts/generics/general_enemy.gd"

enum {
	MAIN, OTR, PLAYER_OTR, PLAYER_TIRED, TAUNT
}
@export var hook : State
@export var hook_big : State
@export var jab : State
@export var taunt : State

var consecutive_jabs = 0
var consecutive_hooks = 0
var total_idle_hits = 0
var in_combo = false

var has_taunted = false
var previous_message = -1

func _ready():
	health = 96
	animations = $Animations
	sprite = $Boss
	falling_sprite = $Boss_Falling
	stamina = 64
	stamina_max = 64
	stamina_next = 48
	guard = [3,3,3,3,3]
	idle_guard = [8,8,8,8,3]
	idle_guard_low = [3,3,3,3,3]
	idle_time_guard_lowered = 0.2
	left_high_recovery_guard = [3,3,3,3,3,1]
	right_high_recovery_guard = [3,3,3,3,3,1]
	left_low_recovery_guard = [3,3,3,3,3,1]
	right_low_recovery_guard = [3,3,3,3,3,1]
	schedule_state = MAIN
	enemy_schedule = {MAIN: [0x10200, 0x10040, jab, 0x10080, hook, 0x100c0, jab, 
		0x10040, 0x20109, 0x10050, hook, 0x30001],
		PLAYER_OTR: [0x10050, 0x10030, hook, 0x20104, 0x10010, jab, 0x20007, 0x10040, hook, 0x30000],
		OTR: [0x1000f0, jab, 0x20003, 0x10010, hook, 0x30000],
		PLAYER_TIRED: [0x10010, hook, 0x20003, 0x10040, hook, 0x30000],
		TAUNT: [taunt, 0x30000]
	}
	ko_table = {0:[1,0,0,0,0,0,0,0,0,0,0], 1:[72,0,1,0,3], 2:[46,0,0,0,0,1,0,0,3], 3:[32,0,1,0,0,0,0,1,0,3], 4:[1,0,0,0,0,0,0,0,0,2,0]}
	state_machine.init(self)
	handle_state_schedule()

func handle_state():
	#if different points in the schedule index is needed just make variable for it
	var prior_state = schedule_state
	if player.stamina < 1:
		schedule_state = PLAYER_TIRED
		#print("player tired")
	else:
		if schedule_state == PLAYER_TIRED:
			schedule_state = MAIN
			#print("Main from player tired")
		if schedule_state == TAUNT && has_taunted == true:
			schedule_state = MAIN
			#print("Main from taunt")
		if advantage_state == 1:
			schedule_state = OTR
			#print("OTR")
		elif advantage_state == 2:
			schedule_state = PLAYER_OTR
			#print("player OTR")
		else:
			schedule_state = MAIN
			#print("Main from else")
	if prior_state != schedule_state:
		if schedule_state == MAIN:
			schedule_index = 1
		else:
			schedule_index = 0
		handle_state_schedule()
		#print("New schedule")

func check_conditions(value, result, state):
	pass
	if state == $State_Machine/Idle && (result == 2 || result == 3):
		total_idle_hits += 1
		if !has_taunted && total_idle_hits > 8:
			schedule_state = TAUNT
			schedule_timer = -1
			schedule_index = 0
	#if !has_taunted:
		#for i in 4:
			#if idle_guard[i] == 2:
				#idle_guard[i] = 3 
		#if result == 1:
			#in_combo = true
			#consecutive_idle_hits = 0
		#if result > 3:
			#consecutive_idle_hits = 0
	#if (result == 3 || result == 2):
		#if !has_taunted && in_combo:
			#in_combo = false
			#if (value >> 8 & 7) < 2:
				#idle_guard[0] = 8
				#idle_guard[1] = 8
				#idle_guard[2] = 3
				#idle_guard[3] = 3
			#else:
				#idle_guard[0] = 8
				#idle_guard[1] = 8
				#idle_guard[2] = 3
				#idle_guard[3] = 3
		#if (state == $State_Machine/High_Sent_Left || state == $State_Machine/High_Sent_Right
		 #|| state == $State_Machine/Low_Sent_Left || state == $State_Machine/Low_Sent_Right):
			#consecutive_idle_hits = 0
			#consecutive_recovery_hits += 1
			#if consecutive_recovery_hits > 1:
				#left_high_recovery_guard = [2,2,2,2,3,1]
				#right_high_recovery_guard = [2,2,2,2,3,1]
				#left_low_recovery_guard = [2,2,2,2,3,1]
				#right_low_recovery_guard = [2,2,2,2,3,1]
		#else:
			#if !has_taunted && state == $State_Machine/Idle:
				##print("cons idle hit")
				#consecutive_idle_hits += 1
				#total_idle_hits += 1
				#if consecutive_idle_hits > 0 && consecutive_idle_hits % 3 == 0:
					#if (value >> 8 & 7) < 2:
						#idle_guard[0] = 8
						#idle_guard[1] = 8
						#idle_guard[2] = 3
						#idle_guard[3] = 3
					#else:
						#idle_guard[0] = 3
						#idle_guard[1] = 3
						#idle_guard[2] = 8
						#idle_guard[3] = 8
				#if consecutive_idle_hits == 8:
					#for i in 4:
						#if idle_guard[i] == 3:
							#idle_guard[i] = 2
				#if total_idle_hits > 8:
					#var temp_star = idle_guard[4]
					#idle_guard = [8,8,8,8,temp_star]
					##stamina_regain_timer = -1000
					#$State_Machine/Idle.animation = "idle_up"
					#schedule_state = TAUNT
					#schedule_timer = -1
					#schedule_index = 0
			#else:
				#consecutive_idle_hits = 0
			#consecutive_recovery_hits = 0
			#left_high_recovery_guard = [3,3,3,3,3,1]
			#right_high_recovery_guard = [3,3,3,3,3,1]
			#left_low_recovery_guard = [3,3,3,3,3,1]
			#right_low_recovery_guard = [3,3,3,3,3,1]

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
	$State_Machine/Idle.animation = "idle_up"
	
	handle_state()

func fight_setup():
	ring.background.texture = load("res://assets/backgrounds/Boxing_Ring_v3_1.png")
	ring.enemy_ko_table = ko_table
	
	#player.stamina_max = 24
	#player.stamina = 24
	player.stamina_recovery_threshold = 24
	player.stamina_recovered_amount = 48


func enter_OTR():
	OTR_buffer = 0
	advantage_state |= 1
	animation_speed = 0.92
	animations.speed_scale = animation_speed
	#$Boss.material.set_shader_parameter("replace_color", Color("f878f8"))
	$Boss.material.set_shader_parameter("tolerance", 0.1)
	handle_state()

func exit_OTR():
	#print("OTR exit")
	advantage_state &= 2
	animation_speed = 1
	animations.speed_scale = animation_speed
	$Boss.material.set_shader_parameter("tolerance", 0.0)
	handle_state()
