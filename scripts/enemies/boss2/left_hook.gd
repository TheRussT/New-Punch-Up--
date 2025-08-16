extends Enemy_Damage_State

@export var idle: State
@export var walking_up: State

var next_state: State

@export var shake_magnitude: int
@export var shake_frames: int
@export var can_block: bool
@export var can_parry: bool
@export var is_sent_right: bool
@export var area_hit: int
@export var punch_damage: int
@export var available_hits: int
@export var recovery_hits: int

# Called when the node enters the scene tree for the first time.
func enter():
	parent.sprite.flip_h = 1
	next_state = idle
	parent.animations.play("left_hook")
	parent.animations.advance(0)

func exit():
	parent.sprite.flip_h = 0
	#parent.guard = [8,8,8,8,3]
# Called every frame. 'delta' is the elapsed time since the previous frame.
func process(delta):
	if !parent.animations.is_playing():
		parent.handle_state()
		return next_state
	return null

func damage_player():
	var punch_info = 0
	punch_info = punch_info | shake_magnitude
	punch_info = punch_info << 8
	punch_info = punch_info | shake_frames
	punch_info = punch_info << 2
	punch_info = punch_info | int(can_block)
	punch_info = punch_info << 1
	punch_info = punch_info | int(can_parry)
	punch_info = punch_info << 1
	punch_info = punch_info | int(is_sent_right)
	punch_info = punch_info << 4
	punch_info = punch_info | area_hit
	punch_info = punch_info << 8
	punch_info = punch_info | punch_damage
	
	var result = parent.damage_player(punch_info)
	
	#var result = parent.damage_player(0x203180416)
	if result == 0:
		parent.shake_timer = 0.267
		parent.shake_magnitude = 2
		parent.total_shake_time = 0.267
		next_state = walking_up
	elif result < 3:
		parent.shake_timer = 0.167
		parent.shake_magnitude = 1
		parent.total_shake_time = 0.167
		parent.guard = parent.idle_guard
		parent.available_hits = 1
	elif result == 4:
		parent.shake_timer = 0.267
		parent.shake_magnitude = 3
		parent.total_shake_time = 0.267
	elif result == 5:
		parent.available_hits = available_hits
		parent.recovery_hits = recovery_hits
