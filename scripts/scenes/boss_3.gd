extends "res://scripts/generics/general_enemy.gd"

enum {
	MAIN, OTR, PLAYER_OTR, FOLLOWUP, PLAYER_TIRED, TAUNT
}
@export var jab : State
@export var hook : State
@export var hook_feint : State
@export var left_hook : State
@export var hook_quick : State
@export var uppercut : State
@export var uppercut_left : State
@export var uppercut_feint : State
@export var uppercut_quick : State
@export var special_dodge : State

func _ready():
	dodge_stam = 0
	big_dodge_stam = 2
	animations = $Animations
	sprite = $Boss
	falling_sprite = $Boss_Falling
	stamina = 64
	stamina_max = 64
	stamina_next = 1
	#stamina_regain_threshold = 1000
	idle_cooldown = 0.05
	base_x = 100
	base_y = 88
	idle_guard = [6,6,6,6,3]
	idle_guard_low = [5,5,5,5,3]
	idle_time_guard_lowered = 0.02
	stamina_gain_rate = 1
	guard = [6,6,6,6,3]
	schedule_state = MAIN
	#MAIN: [0x100a0, hook, 0x10080, jab, 0x10040, hook_feint, 0x20207, 0x10080, 0x30002,
	#uppercut, 0x30002, hook, 0x30002]                                                                                      10
	enemy_schedule = {MAIN: [0x10100, left_hook, 0x10028, hook, 0x20506, 0x20006, 0x10060, special_dodge, 0x2090a, 0x10010, 0x10020, uppercut, 
		0x10040, 0x20d14, jab, jab, jab, 0x10070, special_dodge, 0x10040, special_dodge, 0x10028, uppercut_left, 0x30000],
		OTR: [0x10010, jab, jab, 0x10010, uppercut_left, 0x2060a,0x10060, hook, 0x100b0, 0x3000f, 0x10048, special_dodge, 0x10010,
		left_hook, 0x10070, special_dodge, 0x10016, uppercut, 0x30000],
		PLAYER_OTR: [0x100a0, uppercut, 0x10008, uppercut_left, 0x100b0, jab, 0x10070, uppercut, 0x10010, 0x20a0c, uppercut,
		0x30000, 0x10010, jab, 0x30000],
		PLAYER_TIRED: [0x10010, uppercut_left, 0x10060, hook_feint, 0x10040, left_hook, 0x20207, 0x10050, uppercut, 0x30000],
		FOLLOWUP: [uppercut_quick, 0x30000]
	}
	ko_table = {0:[1,0,0,0,0,0,0,0,0,0,0], 1:[1,0,0,0,0,0,0,0,0,0,0]}
	state_machine.init(self)
	handle_state_schedule()

func handle_state():
	var prior_state = schedule_state
	if player.stamina < 1:
		schedule_state = PLAYER_TIRED
		#print("player tired")
	else:
		if schedule_state == PLAYER_TIRED:
			schedule_state = MAIN
			#print("Main from player tired")
		if advantage_state == 1:
			schedule_state = OTR
			#print("OTR")
		elif advantage_state == 2:
			schedule_state = PLAYER_OTR
			#print("player OTR")
		else:
			schedule_state = MAIN
			#print("Main from else")
	if prior_state != schedule_state && health > 0: #might need to change health, just so schedule changes 
													#only haddpen when the enemy is active
		if schedule_state == MAIN:
			schedule_index = 1
		else:
			schedule_index = 0
		handle_state_schedule()

func check_conditions(value, result, state):
	if result == 5 && state_machine.current_state != special_dodge && available_hits > 1:
		#print("state change from check_conds 5")
		available_hits = 0
		state_machine.change_state(special_dodge)
	elif (result == 6 || result == -1) && state_machine.current_state == special_dodge:
		#print("state change from check_conds 6")
		state_machine.change_state(uppercut_quick)

func damage_player(value):
	var result = player.damage(value)
	#if result == 2 or result == 0:
		## If player is hit, the schedule is reset
		#schedule_index = -1
	return result

func between_round_setup(round_number):
	if (stamina >= stamina_max - 1):
		Global.scene_manager.current_scene.player_message = "He's too\nelusive!\nI can only\nmaybe hit\nhim after\nthat huge\nuppercut!"
		Global.scene_manager.current_scene.enemy_message = "Ha! I take\nhits\nbetter\nthan any\nother\nfutbol\nplayer"
	else:
		Global.scene_manager.current_scene.player_message = "I'll wear\nyou down\neventually\nm'babe.\nyou can't\ndodge\nforever!"
		Global.scene_manager.current_scene.enemy_message = "Ref? Ref?!\nhe's\nclearly\ntrying to\nhit me!\nred card!\neject him!"
	Global.scene_manager.current_scene.set_up_messages(round_number)


func fight_setup():
	ring.background.texture = load("res://assets/sprites/backgrounds/Boxing_Ring_v3_3.png")
	ring.enemy_ko_table = ko_table
	
	player.stamina_max = 64
	player.stamina = 64
	player.stamina_recovery_threshold = 40
	player.stamina_recovered_amount = 12

func enter_OTR():
	OTR_buffer = 0
	advantage_state |= 1
	animation_speed = 0.92
	animations.speed_scale = animation_speed
	#$Boss.material.set_shader_parameter("replace_color", Color("f878f8"))
	$State_Machine/Idle.animation = "idle_old"
	$Boss.material.set_shader_parameter("tolerance", 0.1)
	handle_state()

func exit_OTR():
	#print("OTR exit")
	advantage_state &= 2
	animation_speed = 1
	animations.speed_scale = animation_speed
	$State_Machine/Idle.animation = "idle"
	$Boss.material.set_shader_parameter("tolerance", 0.0)
	handle_state()
