extends Node2D

var health = 96
var stamina = 64

var stamina_max = 64

var input_buffer = []
var stars = 0

# everything having to do with hitstop
var shake_timer = -1
var total_shake_time = 0
var shake_magnitude = 0
var shake_function_progress = 0
var stored_x = 0

var stamina_recovery_threshold = 24
var stamina_recovery_progress = 0
var stamina_recovered_amount = 12

var OTR_buffer = 0

var stamina_regain_rate = 1
var stamina_regain_amount = 0.0

var recent_action_multiplier = 1
var idle_multiplier = 0.3
var recent_hits = 0

# bits:  is OTR  is player OTR
#       |   0   |      0      |
# maps to 0 = true neutral 1 = disadvantage 2 = advantage 3 = both are OTR
var advantage_state = 0

@onready var animations = $Animations
@onready var state_machine = $State_Machine
@onready var sprite = $Sprite
@export var enemy : Node2D
@export var ring : Node2D

@export var intro_state : State

func _ready():
	state_machine.init(self)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	process_input()
	if shake_timer >= 0:
		animations.pause()
		shake_timer -= delta
		handle_shake(delta)
	else:
		state_machine.process(delta)
		if stamina < stamina_max:
			stamina_regain_amount += delta * ring.timer_speed * recent_action_multiplier * idle_multiplier
		if stamina_regain_amount >= 0:
			stamina_regain_amount -= 1
			change_stamina(1)

func process_input():
	if Input.is_action_just_pressed("ui_right"):
		input_buffer.push_back("ui_right")
	elif Input.is_action_just_released("ui_right"):
		input_buffer.erase("ui_right")
	if Input.is_action_just_pressed("ui_left"):
		input_buffer.push_back("ui_left")
	elif Input.is_action_just_released("ui_left"):
		input_buffer.erase("ui_left")
	if Input.is_action_just_pressed("ui_down"):
		input_buffer.push_back("ui_down")
	elif Input.is_action_just_released("ui_down"):
		input_buffer.erase("ui_down")
	if Input.is_action_just_pressed("ui_up"):
		input_buffer.push_back("ui_up")
	elif Input.is_action_just_released("ui_up"):
		input_buffer.erase("ui_up")
	if Input.is_action_just_pressed("ui_accept"):
		input_buffer.push_back("ui_accept")
	elif Input.is_action_just_released("ui_accept"):
		input_buffer.erase("ui_accept")
	if Input.is_action_just_pressed("ui_cancel"):
		input_buffer.push_back("ui_cancel")
	elif Input.is_action_just_released("ui_cancel"):
		input_buffer.erase("ui_cancel")
	if Input.is_action_just_pressed("ui_select"):
		input_buffer.push_back("ui_select")
	elif Input.is_action_just_released("ui_select"):
		input_buffer.erase("ui_select")
	if (!Input.is_action_pressed("ui_right") and !Input.is_action_pressed("ui_left") and !Input.is_action_pressed("ui_down") and !Input.is_action_pressed("ui_up")
	 and !Input.is_action_pressed("ui_accept") and !Input.is_action_pressed("ui_cancel") and !Input.is_action_pressed("ui_select")):
		input_buffer.clear()

func handle_shake(delta):
	if shake_timer <= 0:
		animations.play()
		shake_function_progress = 0
	else:
		shake_function_progress += 1 * delta + 2 * (shake_timer/total_shake_time)
		$Sprite.position.x = int(0.5 + (shake_magnitude * (shake_timer/total_shake_time))
		* cos(shake_function_progress)) + stored_x

func initiate_shake_i(time : int, magnitude):
	shake_timer = float(time) / 120
	total_shake_time = shake_timer
	shake_magnitude = magnitude
	stored_x = $Sprite.position.x

func initiate_shake_f(time : float, magnitude):
	shake_timer = time
	total_shake_time = shake_timer
	shake_magnitude = magnitude
	stored_x = $Sprite.position.x

func punch_enemy(value):
	var result = enemy.damage(value)
	#print(result)
	if result == 8: #24
		initiate_shake_f(0.267,2)
		if advantage_state & 1:
			change_stamina(-4)
		else:
			change_stamina(-3)
	elif result == 7: #20
		initiate_shake_f(0.233,1)
		change_stamina(-1)
	elif result == 6: #20
		initiate_shake_f(0.233,0)
		change_stamina(-2)
	elif result == 5: #12
		initiate_shake_f(0.1,0)
		change_stamina(-1)
	elif result == 4: #8
		initiate_shake_f(0.067,0)
	elif result == 3: #20
		if (value >> 8) & 7 == 4:
			initiate_shake_f(0.267,2)
		else:
			initiate_shake_f(0.167,2)
	elif result == 1: #6
		if (value >> 8) & 7 == 4:
			initiate_shake_f(0.267,2)
		else:
			initiate_shake_f(0.05,2)
	elif result == 0: #24
		if (value >> 8) & 7 == 4:
			initiate_shake_f(0.333,4)
		else:
			initiate_shake_f(0.2,3)
	elif result == 2: #20
		initiate_shake_f(0.167,3)
		stars += 1
		#print("number of stars: " + str(stars))
		ring.handle_stars(stars)
	ring.update_player_stam(stamina)
	return result

func change_stamina(value):
	if advantage_state & 1: #OTR
		if value > 0:
			OTR_buffer += value
			if OTR_buffer >= 16:
				exit_OTR()
				stamina += 16
		else:
			stamina += value
			OTR_buffer += value
			if OTR_buffer < 0:
				OTR_buffer = 0 
			if stamina < 1:
				ring.player_tired()
	else:
		stamina += value
		if stamina <= 16:
			enter_OTR()
			# do ring settings
		elif stamina > stamina_max:
			stamina = stamina_max
	ring.update_player_stam(stamina)

func enter_OTR():
	OTR_buffer = 0
	advantage_state |= 1
	$Sprite.material.set_shader_parameter("replace_color", Color("f878f8"))
	if $Sprite.material.get_shader_parameter("tolerance") != 1.0:
		$Sprite.material.set_shader_parameter("tolerance", 0.1)
	ring.player_enter_OTR()
	#inform ring


func exit_OTR():
	advantage_state &= 6
	if $Sprite.material.get_shader_parameter("tolerance") != 1.0:
		$Sprite.material.set_shader_parameter("tolerance", 0.0)
	change_stamina(16)
	ring.player_exit_OTR()
	#inform ring

func exit_tired():
	$Sprite.material.set_shader_parameter("tolerance", 0.0)
	stamina_recovery_progress = 0
	change_stamina(64 - 16)
	exit_OTR()

func damage(value):
	var result = state_machine.current_state.damage(value)
	ring.update_player_health(health)
	#ring.update_player_stam(stamina)
	return result

func activate(value):
	state_machine.current_state.activate(value)

func event_hit(time):
	recent_hits += 1
	recent_action_multiplier = 0.2
	await get_tree().create_timer(time)
	recent_hits -= 1
	if recent_hits < 1:
		recent_action_multiplier = 1
