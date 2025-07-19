extends Node2D

@onready var animations
@onready var state_machine = $State_Machine
@onready var sprite = $Boss
@onready var star = $Star
@onready var falling_sprite
@export var player : Node2D
@export var ring : Node2D

var health = 96
var stamina 
var stamina_max
var stamina_next 

var base_x = 108
var base_y = 86

var idle_guard = [0,0,0,0,0]
var guard = idle_guard

var shake_timer = -1
var total_shake_time = 0
var shake_magnitude = 0
var shake_function_progress = 0

var idle_cooldown = 0.25

var stamina_regain_timer = 0.0

var available_hits = 1

# first schedule implementation 1 = timer, 2 = split jump addresses, 3 = jump
var enemy_schedule
var schedule_timer = 0
var schedule_index = 0

var schedule_state 

# Called when the node enters the scene tree for the first time.
func _ready():
	state_machine.init(self)
	handle_state_schedule()
	

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	#print(guard)
	if shake_timer >= 0:
		animations.pause()
		shake_timer -= delta
		handle_shake(delta)
	else:
		state_machine.process(delta)

func handle_shake(delta):
	if shake_timer <= 0:
		shake_function_progress = 0
		position.x = base_x
		animations.play()
	else:
		#print(shake_function_progress)
		shake_function_progress += 1 * delta + 2 * (shake_timer/total_shake_time)
		position.x = base_x + int(0.5 + (shake_magnitude * (shake_timer/total_shake_time))
		* cos(shake_function_progress))

func damage(value):
	var state = state_machine.current_state
	var result = state_machine.damage(value)
	if result >= 0:
		check_conditions(value, result, state)
		ring.update_enemy_health(health)
		ring.update_enemy_stam(stamina)
	return result

func damage_player(value):
	return player.damage(value)

func set_guard(up_left, up_right, down_left, down_right, star, hits):
	guard = [up_left, up_right, down_left, down_right, star]
	available_hits = hits

func advance_state():
	schedule_index += 1
	handle_state_schedule()

func handle_state_schedule():
	var curr_sch = enemy_schedule[schedule_state][schedule_index]
	#print("state changed to: " + str(curr_sch) + ", " + str(schedule_state)
	#+ ", " + str(schedule_index))
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

func activate(value):
	state_machine.current_state.activate(value)

func check_conditions(value, result, state):
	pass

func fight_setup():
	pass
