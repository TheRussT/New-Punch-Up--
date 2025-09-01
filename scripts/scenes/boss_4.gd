extends "res://scripts/generics/general_enemy.gd"

enum {
	MAIN, LOW, TIRED, ENRAGED, BLIZZARD, TAUNT
}
@export var hook : State
@export var left_hook : State
@export var uppercut : State
@export var jab : State
@export var uppercut_combo : State
@export var taunt : State

var whiteout : ColorRect

var previous_message = -1

func _ready():
	health = 96
	animations = $Animations
	sprite = $Boss
	falling_sprite = $Boss_Falling
	stamina = 255
	stamina_max = 255
	stamina_next = 255
	base_x = 104
	base_y = 98
	idle_guard = [3,3,3,3,3]
	guard = [3,3,3,3,3]
	schedule_state = MAIN
	enemy_schedule = {MAIN: [0x10030, hook, 0x10040, hook, 0x100c0, uppercut, 
		0x20702, 0x100c0, left_hook, 0x2080a, uppercut, 0x30000],
		LOW: [0x10020, jab, 0x10080, left_hook, 0x20005, 0x10040, jab, 0x10030, hook, 
		0x20002],
		TIRED: [0x100020, jab, 0x20003, 0x10060, jab, 0x20006, 0x10010, hook, 
		0x20009, 0x30006],
		ENRAGED: [0x10010, hook, 0x20003, 0x10040, uppercut_combo, 0x20005,
		uppercut_combo, 0x30000],
		BLIZZARD: [0x100c0, uppercut, 0x20003, 0x10040, hook, 0x30000],
		TAUNT: [taunt, 0x30000]
	}
	state_machine.init(self)
	handle_state_schedule()

func handle_state():
	pass
	#if player.stamina < 1:
		#if schedule_state != PLAYER_TIRED:
			#schedule_index = 0
		#schedule_state = PLAYER_TIRED
		##
		##handle_state_schedule()
	#else:
		#if schedule_state == PLAYER_TIRED:
			#schedule_state = MAIN
		#if schedule_state == ENRAGED:
			#pass
		#elif stamina < 10:
			#if schedule_state != TIRED:
				#schedule_index = 0
			#schedule_state = TIRED
		#elif stamina > 11 || schedule_state != TIRED:
			#if health > 48 && schedule_state == LOW:
				#schedule_state = MAIN
				#schedule_index = 0
			#elif health <= 48 && schedule_index == MAIN:
				#schedule_state = MAIN
				#schedule_index = 0
			#

func check_conditions(value, result, state):
	if schedule_state == BLIZZARD:
		if (value >> 9) & 1 == 1 && result < 4: #low shot
			health -= 2
			ring.update_enemy_health(health)
			available_hits = 1

	# Checks 

#func between_round_setup(round_number):
	#if ring.enemy_times_kod == 0:
		#Global.scene_manager.current_scene.player_message = "After he\npunches,\nhe leaves\nhimeself\nwide open!\n...      \nwell, more\nthan usual"
		#Global.scene_manager.current_scene.enemy_message = "Monsieur!\nAre you\nnot aware?\ni come\nfrom a \nlong line\nof sir\nrendre-ers"
	#elif has_taunted && previous_message != 1:
		#Global.scene_manager.current_scene.player_message = "that old\nsir rendre\ngot wise\nand raised\nhis guard.\nAlthough\nhe looks a\nbit winded"
		#Global.scene_manager.current_scene.enemy_message = "I'm not \neven old!\nI'm at the\nen-#cough#\nbeginning\nof my\ncareer!"
		#previous_message = 1
	#elif (ring.player_times_kod > ring.enemy_times_kod ||
	#(ring.player_times_kod == ring.enemy_times_kod && health > player.health)):
		#Global.scene_manager.current_scene.player_message = "I think I\ncan fit in\nsome extra\nhits if I\npunch\nright as\nhe's reco-\nvering!"
		#Global.scene_manager.current_scene.enemy_message = "I need\nthis win\nto get \nover the\nhump...  \nI can't\nlose\nanother 90"
	#else:
		#if ring.enemy_times_kod > ring.player_times_kod:
			#Global.scene_manager.current_scene.player_message = "left right\nleft right\nI'm\nadvancing\non you\nfast,\n\"monsieur\""
			#Global.scene_manager.current_scene.enemy_message = "I was over\nconfident,\ni think\ni'll\ncapitulate\nsoon!"
		#else:
			#Global.scene_manager.current_scene.player_message = "I'll need\nto stay on\nmy toes.\nchip away\nat this\nloser's\nstamina"
			#Global.scene_manager.current_scene.enemy_message = "Why does\nno one\nremember\nany of my\nprevious\nvictories?"
	#Global.scene_manager.current_scene.set_up_messages(round_number)

func taunt_complete():
	schedule_state = BLIZZARD
	#$State_Machine/Idle.animation = "idle_up"
	schedule_index = 0
	$Boss.material.set_shader_parameter("tolerance", 1.0)
	idle_guard = [-1,-1,-1,-1,-1]

func fight_setup():
	ring.background.texture = load("res://assets/backgrounds/Boxing_Ring_4_FinalNES.png")
	whiteout = $Whiteout
	whiteout.reparent(ring, false)

func set_shader_color(color : Color):
	$Boss.material.set_shader_parameter("replace_color", color)
	$Boss.material.set_shader_parameter("replace_color2", color)

func set_blizzard_opacity(opacity : float):
	whiteout.color.a = opacity
