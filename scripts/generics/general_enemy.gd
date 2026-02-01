extends Node2D

@onready var animations
@onready var state_machine = $State_Machine
@onready var sprite = $Boss
@onready var star = $Particles/Star
@onready var spit = $Particles/Spit
@onready var falling_sprite
@export var player : Node2D
@export var ring : Node2D

@export var intro_state : State

var health = 96
var stamina = 64
var stamina_max = 64
var stamina_next 

var base_x = 108
var base_y = 86

var idle_guard = [0,0,0,0,0]
var idle_guard_low = [0,0,0,0,0]
var left_high_recovery_guard = [0,0,0,0,0,0]
var right_high_recovery_guard = [0,0,0,0,0,0]
var left_low_recovery_guard = [0,0,0,0,0,0]
var right_low_recovery_guard = [0,0,0,0,0,0]
var guard = [0,0,0,0,0]

var shake_timer = -1
var total_shake_time = 0
var shake_magnitude = 0
var shake_function_progress = 0

var idle_cooldown = 0.25

var idle_time_guard_lowered = 0
var consecutive_idle_hits = 0

var consecutive_recovery_hits = 0

# new stamina controls
var stamina_gain_rate = 1 # per second
# bits:  is player OTR  is OTR
#       |      0      |    0   |
# maps to 0 = true neutral 1 = disadvantage 2 = advantage 3 = both are OTR
var advantage_state = 0
var animation_speed = 1
var stamina_regain_amount = 0.0
#var stamina_regain_threshold = 3
var OTR_buffer = 0
var OTR_max = 32

var recent_strays = 0
var recent_combos = 0
var recent_player_dodges = 0
var recent_player_parries = 0

var recent_action_multiplier = 1.3
var idle_multiplier = 0.3
var recent_big_actions = 0
var recent_actions = 0


var available_hits = 1
var recovery_hits = 0

var star_flag = false

# first schedule implementation 1 = timer, 2 = split jump addresses, 3 = jump
var enemy_schedule
var ko_table 
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
	if stamina < stamina_max:
		stamina_regain_amount += delta * ring.timer_speed * stamina_gain_rate * recent_action_multiplier * idle_multiplier
		if stamina_regain_amount >= 0:
			stamina_regain_amount -= 1
			change_stamina(1)
	# print(recent_strays)

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
		ring.update_enemy_health(health)
		if result < 4: 
			if state == $State_Machine/Idle:
				consecutive_idle_hits += 1
			else:
				consecutive_idle_hits = 0
		check_conditions(value, result, state)
		#ring.update_enemy_stam(stamina)
	return result

func damage_player(value):
	return player.damage(value)

func set_guard(up_left, up_right, down_left, down_right, star_guard, hits):
	guard = [up_left, up_right, down_left, down_right, star_guard]
	#available_hits = hits

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

func change_stamina(value : int, handles_stamina_loss : bool = false):
	if advantage_state & 1: #on the ropes
		if value > 0: #gaining stamina
			OTR_buffer += value
			#could have it flash when enemy is close to recovering
			if OTR_buffer >= OTR_max:
				#OTR_buffer = 0
				#print("change stamina OTR")
				exit_OTR()
				stamina += 16
				#undo ring settings
		else: #losing stamina
			stamina += value
			# can turn off so enemy buffers only receive positive changes
			OTR_buffer += value
			if OTR_buffer < 0:
				OTR_buffer = 0
	else:
		stamina += value
		if stamina <= 16:
			enter_OTR()
			# do ring settings
		elif stamina > stamina_max:
			stamina = stamina_max
	ring.update_enemy_stam(stamina)
	if handles_stamina_loss:
		if stamina < 1:
			state_machine.change_state($State_Machine/Stamina_Loss)

func enter_OTR():
	OTR_buffer = 0
	advantage_state |= 1
	animation_speed = 0.92
	animations.speed_scale = animation_speed
	#ring.enemy_enter_OTR()

func exit_OTR():
	#print("parent OTR exit")
	advantage_state &= 6
	animation_speed = 1
	animations.speed_scale = animation_speed
	#ring.enemy_exit_OTR()

func exit_stamina_loss():
	advantage_state &= 3
	#print("exit OTR called from stamina_loss")
	exit_OTR()
	stamina = 0
	change_stamina(stamina_next)

func add_stray():
	recent_strays += 1
	#print("adding - strays are now " + str(recent_strays))
	await get_tree().create_timer(5).timeout
	recent_strays -= 1
	#print("removing - strays are now " + str(recent_strays))

func add_combo():
	recent_combos += 1
	#print("adding - combos are now " + str(recent_combos))
	await get_tree().create_timer(5).timeout
	recent_combos -= 1
	#print("removing - combos are now " + str(recent_combos))

func player_parry():
	change_stamina(-6 - 2 * recent_player_parries, true)
	add_player_parries()

func player_dodge(value):
	change_stamina(-value - recent_player_dodges, true)
	#add_player_dodges()

func add_player_parries():
	recent_player_parries += 1
	await get_tree().create_timer(8).timeout
	recent_player_parries -= 1

#func add_player_dodges():
	#recent_player_dodges += 1
	#await get_tree().create_timer(5).timeout
	#recent_player_dodges -= 1

func event_action(time):
	if recent_big_actions < 1:
		recent_actions += 1
		recent_action_multiplier = 1
		await get_tree().create_timer(time)
		recent_actions -= 1
		if recent_actions < 1:
			recent_action_multiplier = 1.5

func event_big_action(time):
	recent_big_actions += 1
	recent_action_multiplier = 0.1
	await get_tree().create_timer(time)
	recent_big_actions -= 1
	if recent_big_actions < 1:
		event_action(time)

func between_round_setup(round_number : int):
	#can maybe verify this is the between fights scene
	
	Global.scene_manager.current_scene.player_message = "Huh, that's\nweird. you\nshouldn't\nbe able to\nsee this\nmessage"
	Global.scene_manager.current_scene.enemy_message = "That oaf\nof a\ndeveloper\nclearly\ndidn't\nknow what\nthey're\ndoing"
	Global.scene_manager.current_scene.set_up_messages(round_number)
