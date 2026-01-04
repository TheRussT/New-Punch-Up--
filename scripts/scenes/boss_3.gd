extends "res://scripts/generics/general_enemy.gd"

enum {
	MAIN, SEVEN, SIX, FIVE, FOUR, THREE, TWO, ONE, PLAYER_TIRED, FOLLOWUP
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
	stamina = 8
	stamina_max = 8
	stamina_next = 1
	#stamina_regain_threshold = 1000
	idle_cooldown = 0.05
	base_x = 100
	base_y = 88
	idle_guard = [6,6,6,6,3]
	guard = [6,6,6,6,3]
	schedule_state = MAIN
	#MAIN: [0x100a0, hook, 0x10080, jab, 0x10040, hook_feint, 0x20207, 0x10080, 0x30002,
	#uppercut, 0x30002, hook, 0x30002]
	enemy_schedule = {MAIN: [0x10100, jab, 0x10000, jab, 0x10000, jab, 0x10000, uppercut, 0x100a0, 0x30001],
		SEVEN: [0x100f0, hook, 0x10012, left_hook, 0x10012, hook, 0x10012, uppercut, 0x100a0, 0x30001],
		SIX: [0x100e0, jab, 0x10000, hook, 0x10012, uppercut_left, 0x10016, uppercut, 0x100a0, 0x30001],
		FIVE: [0x100d0, jab, 0x10000, jab, 0x10000, uppercut_left, 0x10080, left_hook, 0x1000c, uppercut, 0x100a0, 0x30001],
		FOUR: [0x100d0, hook, 0x2030d, 0x1000a, hook, 0x1000a, jab, 0x10070, hook, 0x1000a, left_hook, 0x1000c, 0x30016, 0x1000f, left_hook, 0x10040,
		uppercut_left, 0X10010, jab, 0x10000, jab, 0x10028, uppercut, 0x100a0, 0x30001],
		THREE: [0x100c0, jab, 0x20315, jab, 0x20517, jab, 0x20719, jab, 0x3001b, 0x10010, hook, 0x10009, left_hook, 0x1000a, hook, 0x10009, left_hook,
		0x1000a, uppercut, 0x100a0, 0x30001, uppercut_left, 0x30009, uppercut_left, 0x3000b, uppercut_left, 0x3000d, uppercut_left, 0X3000f],
		TWO: [0x100c0, hook_feint, 0x20308, jab, 0x10020, 0x30008, left_hook, 0x10029, hook_feint, 0x20a0f, left_hook, 0x10009, uppercut_left, 0x10029, 
		0x30015, jab, 0x10000, jab, 0x10000, jab, 0x10020, hook_feint, 0x10010, hook_feint, uppercut, 0x100a0, 0x30001],
		ONE: [0x100b0, uppercut, 0x100a0, 0x30001],
		PLAYER_TIRED: [0x10010, uppercut, 0x20003, 0x10040, hook, 0x30000],
		FOLLOWUP: [uppercut_quick, 0x30000]
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
		var new_state = schedule_state
		new_state = MAIN
		if new_state == MAIN:
			if stamina == 7:
				new_state = SEVEN
			elif stamina == 6:
				new_state = SIX
			elif stamina == 5:
				new_state = FIVE
			elif stamina == 4:
				$State_Machine/Idle.animation = "idle_old"
				new_state = FOUR
			elif stamina == 3:
				new_state = THREE
			elif stamina == 2:
				new_state = TWO
			elif stamina == 1:
				new_state = ONE
		if new_state != schedule_state:
			# print(str(schedule_state) +" -> " + str(new_state))
			schedule_state = new_state
			schedule_index = 0

func check_conditions(value, result, state):
	if result == 5:
		state_machine.change_state(special_dodge)
	if result == 6:
		schedule_index = 0
		schedule_timer = 0
		schedule_state = FOLLOWUP
		#state_machine.change_state(uppercut_quick)
	
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

func damage_player(value):
	var result = player.damage(value)
	if result == 2 or result == 0:
		# If player is hit, the schedule is reset
		schedule_index = -1
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
	ring.background.texture = load("res://assets/backgrounds/Boxing_Ring_3_FinalNES.png")
	ring.enemy_ko_table = ko_table
	
	player.stamina_max = 8
	player.stamina = 8
	player.stamina_recovery_threshold = 40
	player.stamina_recovered_amount = 12
