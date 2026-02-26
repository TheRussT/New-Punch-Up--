extends "res://scripts/generics/general_enemy.gd"

enum {
	MAIN, OTR, PLAYER_OTR, BLIZZARD, POST_BLIZZ, TAUNT
}
@export var hook : State
@export var left_hook : State
@export var uppercut : State
@export var jab : State
@export var uppercut_combo : State
@export var taunt : State
@export var stamina_loss : State

var whiteout : ColorRect

var blizzard_count = 1
var is_stamina_blizzard = false
var blizzard_hits = 0
var blizzard_player_hits = 0

var previous_message = -1

func _ready():
	health = 96
	animations = $Animations
	sprite = $Boss
	falling_sprite = $Boss_Falling
	stamina = 64
	stamina_max = 64
	stamina_next = 48
	stamina_gain_rate = 4
	base_x = 100
	base_y = 90
	idle_guard = [8,8,8,8,3]
	idle_guard_low = [3,3,3,3,3]
	idle_time_guard_lowered = 0.02
	guard = [3,3,3,3,3]
	schedule_state = MAIN
	enemy_schedule = {MAIN: [0x10030, hook, 0x10040, hook, 0x100c0, uppercut, 
		0x20702, 0x100c0, left_hook, 0x10140, uppercut_combo, 0x30000],
		OTR: [0x100c0, 0x30000],
		PLAYER_OTR: [0x10020, jab, 0x10080, jab, 0x100a0, jab, 0x10120, uppercut_combo, 0x20009, left_hook, 0x20009],
		BLIZZARD: [0x100c0, uppercut, 0x20003, 0x10040, hook, 0x20006, uppercut_combo, 0x30000],
		TAUNT: [0x10001, taunt, 0x30000],
		POST_BLIZZ: [stamina_loss, 0x30000]
	}
	ko_table = {0:[1,0,0,0,0,0,0,0,0,0,0], 1:[84,0,0,0,0,0,0,0,3], 2:[72,0,3], 3:[64,1,0,3], 4:[56,0,1,0,3], 5:[48,0,0,1,0,0,0,3], 6:[24,0,1,0,0,0,0,0,0,3]}
	state_machine.init(self)
	handle_state_schedule()

func handle_state():
	var prior_state = schedule_state
	if player.stamina < 1:
		if schedule_state != BLIZZARD:
			if schedule_state != TAUNT:
				schedule_index = 0
				is_stamina_blizzard = true
			schedule_state = TAUNT
		#
		#handle_state_schedule()
	else:
		if schedule_state == BLIZZARD:
			if is_stamina_blizzard:
				schedule_state = MAIN
				undo_blizzard()
		#if schedule_state == POST_BLIZZ:
			#schedule_state = MAIN
		#if ring.time < 120 && blizzard_count == 1:
			
		elif advantage_state == 1:
			schedule_state = OTR
			#print("OTR")
		elif advantage_state == 2:
			schedule_state = PLAYER_OTR
			#print("player OTR")
		else:
			schedule_state = MAIN
	if prior_state != schedule_state:
		schedule_index = 0
		handle_state_schedule()

func check_conditions(value, result, state):
	if schedule_state == BLIZZARD && result < 4:
		blizzard_hits += 1
		available_hits = 1
		if blizzard_player_hits == 0:
			if blizzard_hits > 5:
				if health > 0:
					state_machine.change_state(stamina_loss)
				blizzard_hits = 0
				blizzard_player_hits = 0
				schedule_index = 0
				schedule_timer = -1
				undo_blizzard()
		elif blizzard_hits > 3:
			blizzard_hits = 0
			blizzard_player_hits = 0
			schedule_index = 0
			schedule_timer = -1
			undo_blizzard()

	# Checks 

func between_round_setup(round_number):
	Global.scene_manager.current_scene.player_message = "Man, this\nguy's the\nreal deal,\nI have to\nwatch my\nstamina"
	Global.scene_manager.current_scene.enemy_message = "..."
	Global.scene_manager.current_scene.set_up_messages(round_number)
	undo_blizzard()

func taunt_complete():
	activate_player_shader()
	schedule_state = BLIZZARD
	#$State_Machine/Idle.animation = "idle_up"
	schedule_index = 0
	$Boss.material.set_shader_parameter("tolerance", 1.0)
	idle_guard = [-1,-1,-1,-1,-1]

func undo_blizzard():
	deactivate_player_shader()
	$Boss.material.set_shader_parameter("tolerance", 0)
	whiteout.color.a = 0
	idle_guard = [8,8,8,8,3]
	schedule_state = MAIN

func fight_setup():
	ring.background.texture = load("res://assets/sprites/backgrounds/Boxing_Ring_v3_4.png")
	whiteout = $Whiteout
	whiteout.reparent(ring, false)
	ring.enemy_ko_table = ko_table
	ring.event_table = [90, 0, 0, 160, 60, 0, 120, 30, 0]
	
	#player.stamina_max = 8
	#player.stamina = 8
	player.stamina_recovery_threshold = 60
	player.stamina_recovered_amount = 6

func set_shader_color(color : Color):
	$Boss.material.set_shader_parameter("replace_color", color)
	$Boss.material.set_shader_parameter("replace_color2", color)

func activate_player_shader():
	player.sprite.material.set_shader_parameter("tolerance", 1.0)
	player.sprite.material.set_shader_parameter("replace_color2", Color(0.352941, 0.352941, 0.352941))

func deactivate_player_shader():
	if player.advantage_state & 1:
		player.sprite.material.set_shader_parameter("tolerance", 0.1)
	else:
		player.sprite.material.set_shader_parameter("tolerance", 0.0)
	player.sprite.material.set_shader_parameter("replace_color2", Color("f878f8"))

func set_blizzard_opacity(opacity : float):
	whiteout.color.a = opacity

func schedule_event():
	if schedule_state != BLIZZARD:
		blizzard_count = 0
		schedule_state = TAUNT
		schedule_index = 0
		is_stamina_blizzard = false

func damage_player(value):
	var result = player.damage(value)
	if schedule_state == BLIZZARD && result < 3:
		blizzard_player_hits += 1
	return result
