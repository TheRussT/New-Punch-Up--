extends "res://scripts/generics/general_enemy.gd"

enum {
	MAIN, LOW, TIRED, ENRAGED, PLAYER_TIRED, TAUNT
}
@export var hook : State
@export var left_hook : State
@export var hook_big : State
@export var jab : State
@export var left_hook_big : State
@export var taunt : State

var rage = 0

var has_taunted = false
var previous_message = -1


func _ready():
	health = 96
	animations = $Animations
	sprite = $Boss
	falling_sprite = $Boss_Falling
	stamina = 24
	stamina_max = 24
	stamina_next = 18
	base_x = 100
	base_y = 88
	idle_guard = [8,8,8,8,3]
	guard = [8,8,8,8,3]
	schedule_state = MAIN
	enemy_schedule = {MAIN: [0x100d0, jab, 0x10040, jab, 0x100c0, hook, 
		0x20705, left_hook, 0x30000],
		LOW: [0x10020, jab, 0x10080, left_hook, 0x20005, 0x10040, jab, 0x10030, hook, 
		0x20002],
		TIRED: [0x100020, jab, 0x20003, 0x10060, jab, 0x20006, 0x10010, hook_big, 
		0x20009, 0x30006],
		ENRAGED: [0x10010, hook_big, 0x20003, 0x10040, left_hook_big, 0x20005,
		left_hook_big, 0x30000],
		PLAYER_TIRED: [0x10010, hook, 0x20003, 0x10040, hook, 0x30000],
		TAUNT: [taunt, 0x30000]
	}
	ko_table = {0:[1,0,0,0,0,0,0,0,0,0,0], 1:[80,0,0,3], 2:[64,0,0,1,0,3], 3:[56,0,1,0,1,0,1,0,3], 4:[48,3]}
	state_machine.init(self)
	handle_state_schedule()

func handle_state():
	if player.stamina < 1:
		if schedule_state != PLAYER_TIRED:
			schedule_index = 0
		schedule_state = PLAYER_TIRED
		#
		#handle_state_schedule()
	else:
		if schedule_state == PLAYER_TIRED:
			schedule_state = MAIN
		if schedule_state == ENRAGED:
			pass
		elif stamina < 10:
			if schedule_state != TIRED:
				schedule_index = 0
			schedule_state = TIRED
		elif stamina > 11 || schedule_state != TIRED:
			if health > 48 && schedule_state == LOW:
				schedule_state = MAIN
				schedule_index = 0
			elif health <= 48 && schedule_state == MAIN:
				schedule_state = MAIN
				schedule_index = 0
			

func check_conditions(value, result, state):
	if result == 0:
		unrage()
	if schedule_state != ENRAGED:
		if (value >> 9) & 1 == 1 && result < 4: #low shot
			health -= 2
			ring.update_enemy_health(health)
			available_hits = 1
			rage += 1
		if rage > 2:
			schedule_state = TAUNT
			schedule_index = 0
	# Checks 

func between_round_setup(round_number):
	if schedule_state == ENRAGED:
		Global.scene_manager.current_scene.player_message = "Wow! I\nsure\nworked\nthat guy\nup..."
		Global.scene_manager.current_scene.enemy_message = "Rrgh #huf#\nrgh"
	if has_taunted:
		Global.scene_manager.current_scene.player_message = "When he\ngets angry\nhe gets\nsloppy and\nloses\nfocus!"
		Global.scene_manager.current_scene.enemy_message = "I cant\n\"stomach\"\nmany hits.\nhow \"low\".\nHA! Ha!\n...\ndon't aim\nthere ok?"
	else:
		Global.scene_manager.current_scene.player_message = "I think I\ncan\nexploit\nhis soft\nunderbelly\nhe's\ndefinitely\ntrying to\nguard it"
		Global.scene_manager.current_scene.enemy_message = "If you \nthink you\ncan beat\nme, you're\nin de-nile\nHahaha!"
		previous_message = 1
	Global.scene_manager.current_scene.set_up_messages(round_number)
	unrage()

func taunt_complete():
	has_taunted = true
	schedule_state = ENRAGED
	$State_Machine/Idle.animation = "idle_up"
	schedule_index = 0
	stamina = 8
	ring.update_enemy_stam(stamina)

func unrage():
	#print("unrage")
	rage = 0
	if (schedule_state == ENRAGED):
		#$Boss.material.shader_parameters.tolerance = 0.0
		$State_Machine/Idle.animation = "idle"
		schedule_state = MAIN
		handle_state()
		schedule_index = 0
		$Boss.material.set_shader_parameter("tolerance", 0.0)

func fight_setup():
	ring.background.texture = load("res://assets/backgrounds/Boxing_Ring_2_FinalNES.png")
	ring.enemy_ko_table = ko_table
	
	player.stamina_max = 32
	player.stamina = 32
	player.stamina_recovery_threshold = 32
	player.stamina_recovered_amount = 16
