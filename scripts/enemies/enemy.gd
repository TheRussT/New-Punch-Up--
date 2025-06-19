extends Node2D

@onready var animations = $Animations
@onready var state_machine = $State_Machine
@onready var sprite = $Boss
@onready var star = $Star
@onready var falling_sprite = $Boss_Falling
@export var player : Node2D
@export var ring : Node2D

var health = 96
var stamina = 12
var stamina_max = 12
var stamina_next = 10

var guard = [8,8,8,8,3]

var shake_timer = -1
var total_shake_time = 0
var shake_magnitude = 0

var stamina_regain_timer = 0.0

var available_hits = 1

# first schedule implementation 1 = timer, 2 = split jump addresses, 3 = jump
var enemy_schedule
var schedule_timer = 0
var schedule_index = 0

@export var hook : State
@export var hook_big : State
@export var jab : State

enum {
	MAIN, MAIN_TIRED, LOW, LOW_TIRED, PLAYER_TIRED
}
var schedule_state = MAIN

# Called when the node enters the scene tree for the first time.
func _ready():
	state_machine.init(self)
	enemy_schedule = {MAIN: [0x10400, jab, 0x10080, hook, 0x100c0, jab, 0x10040,
		0x20008, 0x10030, hook, 0x30000],
		LOW: [0x10080, hook, 0x20003, 0x10020, hook, 0x20006, 0x10060, jab, 
		0x10090, jab, 0x20008],
		MAIN_TIRED: [0x100020, jab, 0x20003, 0x10060, jab, 0x20006, 0x10010, hook_big, 
		0x20009, 0x30006],
		LOW_TIRED: [0x10010, hook, 0x20003, 0x10080, hook_big, 0x20003],
		PLAYER_TIRED: [0x10010, hook, 0x20003, 0x10040, hook, 0x30000]
	}
	handle_state_schedule()
	

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	#print(guard)
	if shake_timer >= 0:
		animations.pause()
		handle_shake()
		shake_timer -= 1
	else:
		state_machine.process(delta)

func handle_shake():
	if shake_timer <= 0:
		animations.play()
	else:
		if float(shake_timer)/ total_shake_time > 0.5:
			if shake_timer % 4 == 0:
				$Boss.position.x += shake_magnitude
			elif shake_timer % 4 == 2:
				$Boss.position.x -= shake_magnitude
		elif float(shake_timer)/ total_shake_time > 0.0:
			if shake_timer % 6 == 0:
				$Boss.position.x += shake_magnitude / ((total_shake_time/2)/shake_timer + 1)
			elif shake_timer % 6 == 3:
				$Boss.position.x -= shake_magnitude / ((total_shake_time/2)/shake_timer + 1)

func damage(value):
	var result = state_machine.damage(value)
	ring.update_enemy_health(health)
	ring.update_enemy_stam(stamina)
	return result

func set_guard(up_left, up_right, down_left, down_right, star, hits):
	guard = [up_left, up_right, down_left, down_right, star]
	available_hits = hits

func advance_state():
	schedule_index += 1
	handle_state_schedule()

func handle_state_schedule():
	var curr_sch = enemy_schedule[schedule_state][schedule_index]
	if curr_sch is State:
		state_machine.change_state(curr_sch)
	else:
		if curr_sch >> 16 == 1:
			schedule_timer = curr_sch & 0xffff
		elif curr_sch >> 16 == 2:
			if randi_range(0,1) == 0:
				schedule_index = (curr_sch & 0xff)
			else:
				schedule_index = ((curr_sch >> 8) & 0xff)
			handle_state_schedule()
		elif curr_sch >> 16 == 3:
			schedule_index = (curr_sch & 0xffff)
			handle_state_schedule()

func handle_state():
	#if we dont have stamina, change state to stamina_loss
	#if player has no stamina change state to player tired
	#elif 
	if stamina < 1 && state_machine.current_state != $State_Machine/Stamina_Loss:
		state_machine.change_state($State_Machine/Stamina_Loss)
	elif player.stamina < 1:
		if schedule_state != PLAYER_TIRED:
			schedule_index = 0
		schedule_state = PLAYER_TIRED
		handle_state_schedule()
	else:
		if schedule_state == PLAYER_TIRED:
			schedule_state = MAIN
		if health > 48:
			if schedule_state == LOW:
				schedule_state = MAIN
				schedule_index = 0
				handle_state_schedule()
			if schedule_state == LOW_TIRED:
				schedule_state = MAIN_TIRED
				schedule_index = 0
				handle_state_schedule()
			if stamina < 5 && schedule_state == MAIN:
				schedule_state = MAIN_TIRED
				schedule_index = 0
				handle_state_schedule()
			if stamina > 7 && schedule_state == MAIN_TIRED:
				schedule_state = MAIN
				schedule_index = 0
				handle_state_schedule()
		elif health <= 48:
			if schedule_state == MAIN:
				schedule_state = LOW
				schedule_index = 0
				handle_state_schedule()
			if schedule_state == MAIN_TIRED:
				schedule_state = LOW_TIRED
				schedule_index = 0
				handle_state_schedule()
			if stamina < 5 && schedule_state == LOW:
				schedule_state = LOW_TIRED
				schedule_index = 0
				handle_state_schedule()
			if stamina > 7 && schedule_state == LOW_TIRED:
				schedule_state = LOW
				schedule_index = 0
				handle_state_schedule()
	#handle_state_schedule()
	print("schedule: " + str(schedule_state) + " index: " + str(schedule_index))

func activate(value):
	state_machine.current_state.activate(value)
