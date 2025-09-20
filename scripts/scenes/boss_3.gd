extends "res://scripts/generics/general_enemy.gd"

enum {
	MAIN, TIRED, EXHAUSTED, PLAYER_TIRED
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
	animations = $Animations
	sprite = $Boss
	falling_sprite = $Boss_Falling
	stamina = 1
	stamina_max = 16
	stamina_next = 12
	idle_cooldown = 0.05
	base_x = 100
	base_y = 88
	idle_guard = [8,8,8,8,3]
	guard = [8,8,8,8,3]
	schedule_state = MAIN
	#MAIN: [0x100a0, hook, 0x10080, jab, 0x10040, hook_feint, 0x20207, 0x10080, 0x30002,
	#uppercut, 0x30002, hook, 0x30002]
	enemy_schedule = {MAIN: [0x100a0, left_hook, 0x10080, jab, 0x10040, hook, 0x20207, 0x10080, 0x30002,
	uppercut, 0x30002, hook, 0x30002, uppercut_quick, 0x30002],
		TIRED: [0x100b0, uppercut, 0x10080, uppercut_left, 0x20005, 0x10040, jab, 0x10030, hook, 
		0x20002],
		EXHAUSTED: [0x100f0, hook_feint, 0x10090, uppercut_feint, 0x20005, 0x10040, hook, 
		uppercut, 0x30000],
		PLAYER_TIRED: [0x10010, hook, 0x20003, 0x10040, hook, 0x30000]
	}
	ko_table = {0:[1,0,0,0,0,0,0,0,0,0,0], 1:[1,0,0,0,0,0,0,0,0,0,0]}
	state_machine.init(self)
	handle_state_schedule()

func handle_state():
	if player.stamina < 1:
		if schedule_state != PLAYER_TIRED:
			schedule_index = 0
		schedule_state = PLAYER_TIRED
	else:
		if schedule_state == PLAYER_TIRED:
			schedule_state = MAIN
		if schedule_state == MAIN:
			if stamina < 9:
				schedule_state = TIRED
				$State_Machine/Idle.animation = "idle_old"
				schedule_index = 0
		if schedule_state == TIRED:
			if stamina < 5:
				schedule_state = EXHAUSTED
				schedule_index = 0
			elif stamina > 9:
				schedule_state = MAIN
				schedule_index = 0
		if schedule_state == EXHAUSTED:
			if stamina > 9:
				schedule_state = MAIN
				schedule_index = 0
			elif stamina > 5:
				schedule_state = TIRED
				schedule_index = 0
			

func check_conditions(value, result, state):
	if result == 5:
		state_machine.change_state(special_dodge)
		#if schedule_state == MAIN:
			#if schedule_index == 1 || schedule_index == 5 || schedule_index == 11:
				#schedule_index = 8
			#if schedule_index == 3:
				#schedule_index = 10
	elif result == 8 || result == 6:
		if schedule_state == MAIN:
			schedule_index = 12
			schedule_timer = -1
	
	#if result == 0:
	#if schedule_state != ENRAGED:
		#if (value >> 9) & 1 == 1 && result < 4: #low shot
			#health -= 2
			#ring.update_enemy_health(health)
			#available_hits = 1
			#rage += 1
		#if rage > 1:
			#schedule_state = TAUNT
			#schedule_index = 0
	# Checks 
func between_round_setup(round_number):
	Global.scene_manager.current_scene.player_message = "I'll wear\nyou down\neventually\nm'babe.\nyou can't\ndodge\nforever!"
	Global.scene_manager.current_scene.enemy_message = "Ha! I take\nhits\nbetter\nthan any\nother\nfutbol\nplayer"
	Global.scene_manager.current_scene.set_up_messages(round_number)


func fight_setup():
	ring.background.texture = load("res://assets/backgrounds/Boxing_Ring_3_FinalNES.png")
	ring.enemy_ko_table = ko_table
	
	player.stamina_max = 16
	player.stamina = 16
	player.stamina_recovery_threshold = 40
	player.stamina_recovered_amount = 12
