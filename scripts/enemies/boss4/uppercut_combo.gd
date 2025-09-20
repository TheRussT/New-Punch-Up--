extends Enemy_Damage_State

@export var idle: State
@export var walking_up: State

@export var animation_name: String
@export var number_of_hits: int
@export var shake_magnitude: int
@export var initial_shake_frames: int
@export var final_shake_frames: int
@export var can_block: bool
@export var can_parry: bool
@export var is_sent_right: bool
@export var area_hit: int
@export var punch_damage: int

var next_state: State
var hit_count := 0

# Called when the node enters the scene tree for the first time.
func enter():
	hit_count = 0
	next_state = idle
	parent.animations.play(animation_name)
	parent.animations.advance(0)

func process(delta):
	if !parent.animations.is_playing():
		parent.handle_state()
		return next_state
	return null

func exit():
	parent.sprite.flip_h = 0

func damage_player():
	hit_count += 1
	var punch_info = 0
	punch_info = punch_info | shake_magnitude
	punch_info = punch_info << 8
	if hit_count < number_of_hits:
		punch_info = punch_info | initial_shake_frames
	else:
		punch_info = punch_info | final_shake_frames
	punch_info = punch_info << 2
	punch_info = punch_info | int(can_block)
	punch_info = punch_info << 1
	punch_info = punch_info | int(can_parry)
	punch_info = punch_info << 1
	punch_info = punch_info | (int(is_sent_right) + hit_count) & 1
	punch_info = punch_info << 4
	punch_info = punch_info | area_hit
	punch_info = punch_info << 8
	punch_info = punch_info | punch_damage
	
	var result = parent.damage_player(punch_info)
	#var result = parent.damage_player(0x203181412)
	if result == 0:
		parent.shake_timer = 0.4
		parent.shake_magnitude = 2
		parent.total_shake_time = 0.4
		next_state = walking_up
	elif result < 3:
		parent.shake_timer = 0.333
		parent.shake_magnitude = 1
		parent.total_shake_time = 0.333
		if hit_count == number_of_hits:
			parent.guard = parent.idle_guard
		parent.available_hits = 1
	#elif result == 3 && can_block:
		#parent.shake_timer = 0.4
		#parent.shake_magnitude = 3
		#parent.total_shake_time = 0.4

func check_if_player_kod():
	if next_state == walking_up:
		parent.state_machine.change_state(walking_up)
